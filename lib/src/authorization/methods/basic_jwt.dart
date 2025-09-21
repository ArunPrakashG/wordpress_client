// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/helpers.dart';
import '../authorization_base.dart';
import 'useful_jwt.dart';

/// BasicJwtAuth implements JWT (JSON Web Token) authentication for WordPress APIs.
///
/// This class is based on the WordPress plugin https://github.com/Tmeister/wp-api-jwt-auth.
///
/// ### Usage Example:
///
/// ```dart
/// final auth = BasicJwtAuth(
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
/// ```
///
/// ### Important Note:
///
/// This implementation relies on a WordPress plugin that is not actively maintained.
/// For a more robust and up-to-date JWT authentication, consider using [UsefulJwtAuth] instead.
final class BasicJwtAuth extends IAuthorization {
  /// Creates a new instance of BasicJwtAuth.
  ///
  /// [userName] and [password] are required for authentication.
  /// [events] is optional and can be used to handle authentication events.
  BasicJwtAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;

  /// Number of days until the token expires.
  static const int DAYS_UNTIL_TOKEN_EXPIRY = 3;

  /// Checks if the current authentication is valid.
  @override
  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  /// Checks if the current authentication has expired.
  bool get _isAuthExpiried {
    return _lastAuthorizedTime != null &&
        DateTime.now().difference(_lastAuthorizedTime!).inHours >
            (DAYS_UNTIL_TOKEN_EXPIRY * 24);
  }

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

    if (_client == null) {
      return false;
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
        method: 'POST',
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      return false;
    }

    events?.onResponse?.call(response.data);

    // The classic JWT plugin returns a top-level 'token' when successful.
    final token = response.data['token'] as String?;
    if (isNullOrEmpty(token)) {
      return false;
    }

    _encryptedAccessToken = token;

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
    if (_client == null || isNullOrEmpty(_encryptedAccessToken)) {
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
  /// Returns the authentication URL as a string, or `null` if not authenticated.
  ///
  /// Example:
  /// ```dart
  /// String? authUrl = await auth.generateAuthUrl();
  /// if (authUrl != null) {
  ///   print('Auth URL: $authUrl');
  /// } else {
  ///   print('Not authenticated');
  /// }
  /// ```
  @override
  Future<String?> generateAuthUrl() async {
    if (!await isAuthenticated()) {
      return null;
    }

    return '$scheme $_encryptedAccessToken';
  }

  /// Sets the Dio client for making HTTP requests.
  ///
  /// This method is called internally to set up the HTTP client.
  @override
  void clientFactoryProvider(Dio client) {
    _client = client;
  }

  /// The authentication scheme used for this method (Bearer).
  @override
  String get scheme => 'Bearer';
}
