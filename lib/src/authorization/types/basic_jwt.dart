import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/helpers.dart';
import '../../utilities/wordpress_callback.dart';
import '../../wordpress_client_base.dart';
import 'useful_jwt.dart';

/// Most widely used authentication system, which is most easy to integrate and secure (when compared with basic auth)
///
/// Implemented on basis of https://github.com/Tmeister/wp-api-jwt-auth wordpress plugin.
///
/// ### NOTE
///
/// This plugin isn't in active development and may contain lots of bugs/issues. It is recommended to use [UsefulJwtAuth] instead.
class BasicJwtAuth extends IAuthorization {
  BasicJwtAuth(
    String username,
    String password, {
    WordpressCallback? callback,
  }) : super(username, password, callback: callback);

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;

  static const int kDaysUntilTokenExpiry = 3;
  static const String kAuthScheme = 'Bearer';

  @override
  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get _isAuthExpiried =>
      _lastAuthorizedTime != null &&
      DateTime.now().difference(_lastAuthorizedTime!).inHours >
          (kDaysUntilTokenExpiry * 24);

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

    try {
      final response = await _client!.post<dynamic>(
        'wp-json/jwt-auth/v1/token',
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

      callback?.invokeResponseCallback(response.data);

      if (!(response.data['isSuccess'] as bool) ||
          response.data['token'] == null) {
        return false;
      }

      _encryptedAccessToken = response.data['token'] as String?;

      if (_encryptedAccessToken != null) {
        _lastAuthorizedTime = DateTime.now();
      }

      return _hasValidatedOnce = !isNullOrEmpty(_encryptedAccessToken);
    } on DioError catch (e) {
      callback?.invokeDioErrorCallback(e);
      return false;
    } catch (ex) {
      callback?.invokeUnhandledExceptionCallback(ex as Exception);
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> validate() async {
    if (_client == null || isNullOrEmpty(_encryptedAccessToken)) {
      return false;
    }

    try {
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

      callback?.invokeResponseCallback(response.data);
      return _hasValidatedOnce =
          (response.data['code'] as String) == 'jwt_auth_valid_token';
    } on DioError catch (e) {
      callback?.invokeDioErrorCallback(e);
      return false;
    } catch (ex) {
      callback?.invokeUnhandledExceptionCallback(ex as Exception);
      return false;
    }
  }

  @override
  Future<String?> generateAuthUrl() async {
    if (!await isAuthenticated()) {
      return null;
    }

    return '$kAuthScheme $_encryptedAccessToken';
  }
}
