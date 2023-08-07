// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';

import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../authorization_base.dart';
import 'basic_jwt.dart';

/// Similar to [BasicJwtAuth], this plugin is in active development and has much more features than the previous one. It is recommended to use this plugin instead of the previous one.
///
/// Implemented on basis of https://github.com/usefulteam/jwt-auth wordpress plugin.
final class UsefulJwtAuth extends IAuthorization {
  UsefulJwtAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  String? _encryptedAccessToken;
  DateTime? _lastAuthorizedTime;
  bool _hasValidatedOnce = false;
  Dio? _client;

  static const int DAYS_UNTILS_TOKEN_EXPIRY = 3;

  @override
  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get _isAuthExpiried =>
      _lastAuthorizedTime != null &&
      DateTime.now().difference(_lastAuthorizedTime!).inHours >
          (DAYS_UNTILS_TOKEN_EXPIRY * 24);

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

  @override
  Future<bool> isAuthenticated() async {
    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return true;
    }

    return false;
  }

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
