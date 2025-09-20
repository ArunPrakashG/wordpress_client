// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

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
    this.device,
  });

  /// Optional device identifier to support refresh token rotation per device
  /// as recommended by the usefulteam/jwt-auth plugin.
  final String? device;

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;
  CookieJar? _cookieJar;
  CookieManager? _cookieManager;

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

    if (_client == null) {
      return false;
    }

    if (!_isAuthExpiried &&
        !_hasValidatedOnce &&
        !isNullOrEmpty(_encryptedAccessToken)) {
      return validate();
    }

    // Try using refresh_token cookie if present (no credentials)
    try {
      if (_cookieJar != null) {
        final cookies = await _cookieJar!.loadForRequest(baseUrl);
        final hasRefreshCookie = cookies.any((c) => c.name == 'refresh_token');
        if (hasRefreshCookie) {
          final resp = await _client!.post<dynamic>(
            baseUrl.replace(path: 'wp-json/jwt-auth/v1/token').toString(),
            data: {
              if (device != null && device!.isNotEmpty) 'device': device,
            },
            options: Options(
              method: HttpMethod.post.name,
              contentType: 'application/x-www-form-urlencoded',
              followRedirects: true,
              maxRedirects: 10,
            ),
          );
          if (resp.statusCode == 200 &&
              resp.data != null &&
              (resp.data['success'] == true)) {
            _encryptedAccessToken = resp.data?['data']?['token'] as String?;
            if (_encryptedAccessToken != null) {
              _lastAuthorizedTime = DateTime.now();
              _hasValidatedOnce = true;
              return true;
            }
          }
        }
      }
    } catch (_) {
      // Ignore and fallback to credential flow
    }

    final response = await _client!.post<dynamic>(
      baseUrl.replace(path: 'wp-json/jwt-auth/v1/token').toString(),
      data: {
        'username': userName,
        'password': password,
        if (device != null && device!.isNotEmpty) 'device': device,
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
    // Ensure we have cookie support to capture refresh_token cookies from server
    if (_cookieJar == null) {
      _cookieJar = CookieJar();
      _cookieManager = CookieManager(_cookieJar!);
      if (!_client!.interceptors.contains(_cookieManager)) {
        _client!.interceptors.add(_cookieManager!);
      }
    }
  }

  /// The authentication scheme used. Returns 'Bearer' for UsefulJwtAuth.
  @override
  String get scheme => 'Bearer';

  /// Attempts to refresh the access token using the refresh token cookie.
  /// Returns true if a new access token was obtained.
  Future<bool> tryRefresh() async {
    if (_client == null) {
      return false;
    }

    // First, try using token endpoint with refresh cookie sent automatically by cookie manager
    final resp = await _client!.post<dynamic>(
      baseUrl.replace(path: 'wp-json/jwt-auth/v1/token').toString(),
      data: {
        if (device != null && device!.isNotEmpty) 'device': device,
      },
      options: Options(
        method: HttpMethod.post.name,
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: true,
        maxRedirects: 10,
      ),
    );

    if (resp.statusCode == 200 &&
        resp.data != null &&
        resp.data['success'] == true) {
      final token = resp.data?['data']?['token'] as String?;
      if (!isNullOrEmpty(token)) {
        _encryptedAccessToken = token;
        _lastAuthorizedTime = DateTime.now();
        _hasValidatedOnce = true;
        return true;
      }
    }

    // Fallback to explicit refresh endpoint to rotate refresh token cookie
    final refreshResp = await _client!.post<dynamic>(
      baseUrl.replace(path: 'wp-json/jwt-auth/v1/token/refresh').toString(),
      data: {
        if (device != null && device!.isNotEmpty) 'device': device,
      },
      options: Options(
        method: HttpMethod.post.name,
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: true,
        maxRedirects: 10,
      ),
    );

    // After refresh, try obtaining a new access token again
    if (refreshResp.statusCode == 200) {
      final again = await _client!.post<dynamic>(
        baseUrl.replace(path: 'wp-json/jwt-auth/v1/token').toString(),
        data: {
          if (device != null && device!.isNotEmpty) 'device': device,
        },
        options: Options(
          method: HttpMethod.post.name,
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (again.statusCode == 200 &&
          again.data != null &&
          again.data['success'] == true) {
        final token = again.data?['data']?['token'] as String?;
        if (!isNullOrEmpty(token)) {
          _encryptedAccessToken = token;
          _lastAuthorizedTime = DateTime.now();
          _hasValidatedOnce = true;
          return true;
        }
      }
    }

    return false;
  }
}
