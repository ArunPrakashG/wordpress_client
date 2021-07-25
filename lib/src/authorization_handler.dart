import 'dart:convert';

import 'package:dio/dio.dart';

import 'authorization.dart';
import 'enums.dart';
import 'responses/jwt_token_response.dart';
import 'responses/jwt_validate_response.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';
import 'wordpress_client_base.dart';

class AuthorizationHandler {
  AuthorizationHandler(this._userName, this._password, this._authType, this._hasValidatedOnce, [this._jwtToken = null]) {
    _scheme = '';
    _encryptedAccessToken = '';
    _hasValidatedOnce = false;

    if (isDefault) {
      return;
    }

    switch (_authType) {
      case AuthorizationType.JWT:
        _scheme = 'Bearer';
        _encryptedAccessToken = _jwtToken;
        break;
      case AuthorizationType.BASIC:
        _scheme = 'Basic';
        _encryptedAccessToken = base64Encode('$_userName:$_password');
        break;
    }
  }

  String _userName;
  String _password;
  String _jwtToken;
  AuthorizationType _authType;
  String _scheme;
  String _encryptedAccessToken;
  bool _hasValidatedOnce;

  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get isDefault => isNullOrEmpty(_userName) || isNullOrEmpty(_password);

  bool clear() {
    _encryptedAccessToken = null;
    _hasValidatedOnce = false;
    return true;
  }

  void _handleJwtAuthentication(Dio client, {Callback callback}) async {
    if (_authType != AuthorizationType.JWT || client == null) {
      return;
    }

    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return;
    }

    if (!isNullOrEmpty(_encryptedAccessToken)) {
      bool valid = false;
      _validateExistingJwtToken(client, (isValid) => valid = isValid, callback: callback);

      if (valid) {
        return;
      }
    }

    try {
      final response = await client.post(
        parseUrl(WordpressClient.baseUrl, 'jwt-auth/v1/token'),
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
        return;
      }

      _encryptedAccessToken = JwtToken.fromMap(response.data).token;
    } catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback(e);
      }
    }
  }

  void _validateExistingJwtToken(Dio client, void Function(bool) isValid, {Callback callback}) async {
    return await _validateJwtToken(client, _encryptedAccessToken, isValid, callback: callback);
  }

  void _validateJwtToken(Dio client, String jwtToken, void Function(bool) isValid, {Callback callback}) async {
    if (_authType != AuthorizationType.JWT || client == null || isNullOrEmpty(jwtToken)) {
      return isValid(false);
    }

    try {
      final response = await client.post(
        parseUrl(WordpressClient.baseUrl, 'jwt-auth/v1/token/validate'),
        options: Options(
          method: 'POST',
          headers: {'Authorization': '$_scheme $jwtToken'},
        ),
      );

      if (response == null || response.statusCode != 200) {
        return isValid(false);
      }

      final validationResult = JwtValidate.fromMap(response.data);
      if (validationResult == null || isNullOrEmpty(validationResult.code)) {
        return isValid(false);
      }

      return isValid(_hasValidatedOnce = validationResult.code == 'jwt_auth_valid_token');
    } on DioError catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback(e);
      }

      return isValid(false);
    }
  }

  static Future<RequestOptions> authorizeRequest(RequestOptions requestOptions, Dio client, Authorization auth, {Callback callback}) async {
    if (auth == null || auth.isDefault) {
      return requestOptions;
    }

    AuthorizationHandler handler = AuthorizationHandler(auth.userName, auth.password, auth.authType, auth.isValidatedOnce, auth.jwtToken);

    if (handler._authType == AuthorizationType.JWT) {
      if (handler._hasValidatedOnce && !isNullOrEmpty(handler._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
        return requestOptions;
      }

      handler._handleJwtAuthentication(client, callback: callback);

      if (handler._hasValidatedOnce && !isNullOrEmpty(handler._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
      }

      return requestOptions;
    }

    requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
    return requestOptions;
  }
}
