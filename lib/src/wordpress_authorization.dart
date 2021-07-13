import 'dart:convert';

import 'package:dio/dio.dart';

import 'enums.dart';
import 'responses/jwt_token_response.dart';
import 'responses/jwt_validate_response.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';

class WordpressAuthorization {
  WordpressAuthorization(this._userName, this._password, this.authType, [this._jwtToken = null]) {
    scheme = '';
    _encryptedAccessToken = '';
    _hasValidatedOnce = false;

    if (!isDefault) {
      switch (authType) {
        case AuthorizationType.JWT:
          scheme = 'Bearer';
          _encryptedAccessToken = _jwtToken;
          break;
        case AuthorizationType.BASIC:
          scheme = 'Basic';
          _encryptedAccessToken = base64Encode('$_userName:$_password');
          break;
      }
    }
  }

  String _userName;
  String _password;
  String _jwtToken;
  AuthorizationType authType;
  String scheme;
  String _encryptedAccessToken;
  bool _hasValidatedOnce;

  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get isDefault => isNullOrEmpty(_userName) || isNullOrEmpty(_password);

  bool logout() {
    _encryptedAccessToken = null;
    return true;
  }

  Future<bool> handleJwtAuthentication(String baseUrl, Dio client, void Function(String) tokenCallback, {Callback callback}) async {
    if (authType != AuthorizationType.JWT || client == null || isNullOrEmpty(baseUrl)) {
      return false;
    }

    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return true;
    }

    if (!isNullOrEmpty(_encryptedAccessToken) && await validateExistingToken(baseUrl, client)) {
      return true;
    }

    final response = await client.post(
      parseUrl(baseUrl, 'jwt-auth/v1/token'),
      data: {
        'username': _userName,
        'password': _password,
      },
      options: Options(
        method: 'POST',
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    if (response == null || response.statusCode != 200) {
      return false;
    }

    final token = JwtToken.fromMap(jsonDecode(response.data));
    _encryptedAccessToken = token.token;
    tokenCallback(_encryptedAccessToken);
    return true;
  }

  Future<bool> validateExistingToken(String baseUrl, Dio client) async {
    if (authType != AuthorizationType.JWT || client == null || isNullOrEmpty(baseUrl) || isNullOrEmpty(_encryptedAccessToken)) {
      return false;
    }

    final response = await client.post(
      parseUrl(baseUrl, 'jwt-auth/v1/token/validate'),
      options: Options(
        method: 'POST',
        headers: {'Authorization': '$scheme $_encryptedAccessToken'},
      ),
    );

    if (response == null || response.statusCode != 200) {
      return false;
    }

    final validationResult = JwtValidate.fromMap(jsonDecode(response.data));
    if (validationResult == null || isNullOrEmpty(validationResult.code)) {
      return false;
    }

    return _hasValidatedOnce = validationResult.code == 'jwt_auth_valid_token';
  }

  Future<bool> validateJwtToken(String baseUrl, String accessToken, Dio client) async {
    if (isNullOrEmpty(baseUrl) || isNullOrEmpty(accessToken) || client == null) {
      return false;
    }

    final response = await client.post(
      parseUrl(baseUrl, 'jwt-auth/v1/token/validate'),
      options: Options(
        method: 'POST',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response == null || response.statusCode != 200) {
      return false;
    }

    final validationResult = JwtValidate.fromMap(jsonDecode(response.data));

    if (validationResult == null || isNullOrEmpty(validationResult.code)) {
      return false;
    }

    return validationResult.success;
  }

  static Future<RequestOptions> authorizeRequest(RequestOptions requestOptions, Dio client, String baseUrl, WordpressAuthorization auth,
      {Callback callback}) async {
    if (auth == null || auth.isDefault || isNullOrEmpty(baseUrl)) {
      return requestOptions;
    }

    if (auth.authType == AuthorizationType.JWT && !await auth.handleJwtAuthentication(baseUrl, client, (accessToken) {})) {
      return null;
    }

    requestOptions.headers['Authorization'] = '${auth.scheme} ${auth._encryptedAccessToken}';
    return requestOptions;
  }
}
