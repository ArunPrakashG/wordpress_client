import 'package:dio/dio.dart';

import 'authorization.dart';
import 'enums.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';
import 'wordpress_client_base.dart';

class AuthorizationHandler {
  AuthorizationHandler(
    this._userName,
    this._password,
    this._authType, [
    this._hasValidatedOnce = false,
    this._jwtToken = null,
  ]) {
    _scheme = '';
    _encryptedAccessToken = '';
    _hasValidatedOnce = false;

    if (isDefault) {
      return;
    }

    switch (_authType!) {
      case AuthorizationType.JWT:
      case AuthorizationType.USEFULL_JWT:
        _scheme = 'Bearer';
        _encryptedAccessToken = _jwtToken;
        break;
      case AuthorizationType.BASIC:
        _scheme = 'Basic';
        _encryptedAccessToken = base64Encode('$_userName:$_password');
        break;
    }
  }

  String? _userName;
  String? _password;
  String? _jwtToken;
  AuthorizationType? _authType;
  String? _scheme;
  String? _encryptedAccessToken;
  bool _hasValidatedOnce;
  String? _authString = '';

  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get isDefault => isNullOrEmpty(_userName) || isNullOrEmpty(_password);

  bool clear() {
    _encryptedAccessToken = null;
    _hasValidatedOnce = false;
    return true;
  }

  Future<bool> _isAuthenticated(Dio? client, {Callback? callback}) async {
    if (client == null) {
      return false;
    }

    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return true;
    }

    return false;
  }

  Future<bool> _authenticate(Dio? client, {Callback? callback}) async {
    if (await _isAuthenticated(client, callback: callback)) {
      return true;
    }

    bool authenticated = false;
    switch (_authType!) {
      case AuthorizationType.JWT:
        authenticated = await _handleJwt(client, callback: callback);
        break;
      case AuthorizationType.USEFULL_JWT:
        authenticated = await _handleUsefullJwt(client, callback: callback);
        break;
      case AuthorizationType.BASIC:
        if (!isNullOrEmpty(_encryptedAccessToken)) {
          _hasValidatedOnce = true;
          authenticated = true;
        }
        break;
    }

    if (authenticated) {
      _authString = '${_scheme} ${_encryptedAccessToken}';
    }

    return authenticated;
  }

  Future<bool> _handleJwt(Dio? client, {Callback? callback}) async {
    if (client == null) {
      return false;
    }

    if (!_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return _validateJwtToken(client, _encryptedAccessToken, callback: callback);
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

      print('Auth request send!');

      if (response.statusCode != 200 || response.data == null) {
        return false;
      }

      if (callback != null && callback.responseCallback != null) {
        callback.responseCallback!(response.data);
      }

      if (_authType == AuthorizationType.JWT) {
        if (!(response.data['isSuccess'] as bool) || response.data['token'] == null) {
          return false;
        }

        _encryptedAccessToken = response.data['token'];
        print('[JWT] JWT Token received');
      }

      _hasValidatedOnce = !isNullOrEmpty(_encryptedAccessToken);
      return _hasValidatedOnce;
    } catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback!(e as Exception);
      }

      return false;
    }
  }

  Future<bool> _handleUsefullJwt(Dio? client, {Callback? callback}) async {
    if (client == null) {
      return false;
    }

    if (!_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return _validateUsefullJwtToken(client, _encryptedAccessToken, callback: callback);
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

      if (response.statusCode != 200 || response.data == null) {
        return false;
      }

      if (callback != null && callback.responseCallback != null) {
        callback.responseCallback!(response.data);
      }

      if (response.data['data'] == null || !(response.data['success'] as bool)) {
        return false;
      }

      _encryptedAccessToken = response.data['data']['token'];
      _hasValidatedOnce = !isNullOrEmpty(_encryptedAccessToken);
      return _hasValidatedOnce;
    } catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback!(e as Exception);
      }

      return false;
    }
  }

  Future<bool> _validateUsefullJwtToken(Dio? client, String? jwtToken, {Callback? callback}) async {
    return _validateJwtToken(client, jwtToken, callback: callback);
  }

  Future<bool> _validateJwtToken(Dio? client, String? jwtToken, {Callback? callback}) async {
    if (client == null || _authType != AuthorizationType.JWT || isNullOrEmpty(jwtToken)) {
      return false;
    }

    try {
      final response = await client.post(
        parseUrl(WordpressClient.baseUrl, 'jwt-auth/v1/token/validate'),
        options: Options(
          method: 'POST',
          headers: {'Authorization': '$_scheme $jwtToken'},
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        return false;
      }

      if (callback != null && callback.responseCallback != null) {
        callback.responseCallback!(response.data);
      }

      return _hasValidatedOnce = (response.data['code'] as String) == 'jwt_auth_valid_token';
    } catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback!(e as Exception);
      }

      return false;
    }
  }

  static Future<bool> authorizeRequest(RequestOptions requestOptions, Dio? client, Authorization? auth, {Callback? callback}) async {
    if (auth == null || auth.isDefault) {
      return false;
    }

    if (auth.isValidatedOnce && auth.encryptedToken != null) {
      return true;
    }

    AuthorizationHandler handler = AuthorizationHandler(auth.userName, auth.password, auth.authType, auth.isValidatedOnce, auth.encryptedToken);

    if (await handler._authenticate(client, callback: callback)) {
      auth.authString = handler._authString;
      auth.isValidatedOnce = true;
      auth.encryptedToken = handler._encryptedAccessToken;
      return !isNullOrEmpty(auth.encryptedToken);
    }

    return false;
  }
}
