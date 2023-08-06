// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/helpers.dart';
import '../authorization_base.dart';
import 'useful_jwt.dart';

/// Most widely used authentication system, which is most easy to integrate and secure (when compared with basic auth)
///
/// Implemented on basis of https://github.com/Tmeister/wp-api-jwt-auth wordpress plugin.
///
/// ### NOTE
///
/// This plugin isn't in active development and may contain lots of bugs/issues. It is recommended to use [UsefulJwtAuth] instead.
final class BasicJwtAuth extends IAuthorization {
  BasicJwtAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;

  static const int DAYS_UNTIL_TOKEN_EXPIRY = 3;

  @override
  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get _isAuthExpiried {
    return _lastAuthorizedTime != null &&
        DateTime.now().difference(_lastAuthorizedTime!).inHours >
            (DAYS_UNTIL_TOKEN_EXPIRY * 24);
  }

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

    events?.onResponse?.call(response.data);

    if (!(response.data['isSuccess'] as bool) ||
        response.data['token'] == null) {
      return false;
    }

    _encryptedAccessToken = response.data['token'] as String?;

    if (_encryptedAccessToken != null) {
      _lastAuthorizedTime = DateTime.now();
    }

    return _hasValidatedOnce = !isNullOrEmpty(_encryptedAccessToken);
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

  @override
  Future<String?> generateAuthUrl() async {
    if (!await isAuthenticated()) {
      return null;
    }

    return '$scheme $_encryptedAccessToken';
  }

  @override
  void clientFactoryProvider(Dio client) {
    _client = client;
  }

  @override
  String get scheme => 'Bearer';
}
