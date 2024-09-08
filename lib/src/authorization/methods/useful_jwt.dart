// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';

import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../authorization_base.dart';

/// UsefulJwtAuth implements JWT (JSON Web Token) authentication for WordPress APIs.
///
/// This class is based on the WordPress plugin https://github.com/usefulteam/jwt-auth,
/// which is actively maintained and offers more features compared to the BasicJwtAuth.
///
/// ### Usage Example:
///
/// ```dart
/// final auth = UsefulJwtAuth(
///   userName: 'your_username',
///   password: 'your_password',
/// );
///
/// // Authorize the user
/// bool isAuthorized = await auth.authorize();
///
/// if (isAuthorized) {
///   print('Successfully authorized!');
///   // Use the auth object for subsequent API calls
/// } else {
///   print('Authorization failed.');
/// }
///
/// // Generate auth URL for API requests
/// String? authHeader = await auth.generateAuthUrl();
/// if (authHeader != null) {
///   // Use authHeader in your API requests
///   print('Auth header: $authHeader');
/// }
/// ```
final class UsefulJwtAuth extends IAuthorization {
  /// Creates a new instance of UsefulJwtAuth.
  ///
  /// [userName] and [password] are required for authentication.
  /// [events] is optional and can be used to handle authentication events.
  UsefulJwtAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;

  /// Number of days until the token expires.
  static const int DAYS_UNTILS_TOKEN_EXPIRY = 3;

  /// Checks if the current authentication is valid.
  @override
  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  /// Checks if the current authentication has expired.
  bool get _isAuthExpiried =>
      _lastAuthorizedTime != null &&
      DateTime.now().difference(_lastAuthorizedTime!).inHours >
          (DAYS_UNTILS_TOKEN_EXPIRY * 24);

  /// Authorizes the user with the provided credentials.
  ///
  /// Returns `true` if authorization is successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool success = await auth.authorize();
  /// if (success) {
  ///   print('Authorization successful');
  /// } else {
  ///   print('Authorization failed');
  /// }
  /// ```
  @override
  Future<bool> authorize() async {
    if (isValidAuth) {
      return true;
    }

    if (!_isAuthExpiried &&
        !_hasValidatedOnce &&
        !isNullOrEmpty(_encryptedAccessToken)) {
      return validate();
    }

    final response = await _client!.post<dynamic>(
      baseUrl.replace(path: 'wp-json/jwt-auth/v1/token').toString(),
      data: {
        'username': userName,
        'password': password,
      },
      options: Options(
        method: HttpMethod.post.name,
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: true,
        maxRedirects: 10,
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      return false;
    }

    events?.onResponse?.call(response.data);

    if (response.data['data'] == null || !(response.data['success'] as bool)) {
      return false;
    }

    _encryptedAccessToken = response.data?['data']?['token'] as String?;

    if (_encryptedAccessToken != null) {
      _lastAuthorizedTime = DateTime.now();
    }

    return _hasValidatedOnce = !isNullOrEmpty(_encryptedAccessToken);
  }

  /// Checks if the user is currently authenticated.
  ///
  /// Returns `true` if the user is authenticated, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool isAuth = await auth.isAuthenticated();
  /// print(isAuth ? 'User is authenticated' : 'User is not authenticated');
  /// ```
  @override
  Future<bool> isAuthenticated() async {
    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return true;
    }

    return false;
  }

  /// Validates the current authentication token.
  ///
  /// Returns `true` if the token is valid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool isValid = await auth.validate();
  /// print(isValid ? 'Token is valid' : 'Token is invalid');
  /// ```
  @override
  Future<bool> validate() async {
    if (isNullOrEmpty(_encryptedAccessToken)) {
      return false;
    }

    final authUrl = await generateAuthUrl();
    final response = await _client!.post<dynamic>(
      'wp-json/jwt-auth/v1/token/validate',
      options: Options(
        method: 'POST',
        headers: <String, dynamic>{
          'Authorization': authUrl,
        },
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      return false;
    }

    events?.onResponse?.call(response.data);
    return _hasValidatedOnce =
        (response.data['code'] as String) == 'jwt_auth_valid_token';
  }

  /// Generates an authentication URL with the current token.
  ///
  /// Returns the authentication header as a string, or `null` if not authenticated.
  ///
  /// Example:
  /// ```dart
  /// String? authHeader = await auth.generateAuthUrl();
  /// if (authHeader != null) {
  ///   print('Auth header: $authHeader');
  ///   // Use authHeader in your API requests
  /// }
  /// ```
  @override
  Future<String?> generateAuthUrl() async {
    if (!await isAuthenticated()) {
      return null;
    }

    return '$scheme $_encryptedAccessToken';
  }

  /// Configures the Dio client for this authentication method.
  ///
  /// This method is called internally by the WordPress client.
  @override
  void clientFactoryProvider(Dio client) {
    _client = client;
  }

  /// The authentication scheme used. Returns 'Bearer' for UsefulJwtAuth.
  @override
  String get scheme => 'Bearer';
}
