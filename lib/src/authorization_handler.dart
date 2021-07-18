part of 'internal_requester.dart';

class AuthorizationHandler {
  AuthorizationHandler(this._userName, this._password, this._authType, [this._jwtToken = null]) {
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

  bool logout() {
    _encryptedAccessToken = null;
    return true;
  }

  void handleJwtAuthentication(Dio client, {Callback callback}) async {
    if (_authType != AuthorizationType.JWT || client == null) {
      return;
    }

    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return;
    }

    if (!isNullOrEmpty(_encryptedAccessToken)) {
      bool valid = false;
      validateExistingJwtToken(client, (isValid) => valid = isValid, callback: callback);

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
    } on DioError catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback(e);
      }
    }
  }

  void validateExistingJwtToken(Dio client, void Function(bool) isValid, {Callback callback}) async {
    return await validateJwtToken(client, _encryptedAccessToken, isValid, callback: callback);
  }

  void validateJwtToken(Dio client, String jwtToken, void Function(bool) isValid, {Callback callback}) async {
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

    AuthorizationHandler handler = AuthorizationHandler(auth.userName, auth.password, auth.authType, auth.jwtToken);

    if (handler._authType == AuthorizationType.JWT) {
      if (handler._hasValidatedOnce && !isNullOrEmpty(handler._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
        return requestOptions;
      }

      handler.handleJwtAuthentication(client, callback: callback);

      if (handler._hasValidatedOnce && !isNullOrEmpty(handler._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
      }

      return requestOptions;
    }

    requestOptions.headers['Authorization'] = '${handler._scheme} ${handler._encryptedAccessToken}';
    return requestOptions;
  }
}
