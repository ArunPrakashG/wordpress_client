// ignore_for_file: avoid_returning_this

import '../enums.dart';
import '../utilities/callback.dart';
import 'authorization_base.dart';
import 'authorization_methods/basic_auth.dart';
import 'authorization_methods/basic_jwt.dart';
import 'authorization_methods/useful_jwt.dart';

class AuthorizationBuilder {
  String? _userName;
  String? _password;
  AuthorizationType? _type;
  Callback? _callback;

  AuthorizationBuilder withUserName(String? userName) {
    _userName = userName;
    return this;
  }

  AuthorizationBuilder withPassword(String? password) {
    _password = password;
    return this;
  }

  AuthorizationBuilder withType(AuthorizationType type) {
    _type = type;
    return this;
  }

  AuthorizationBuilder withCallback(Callback? callback) {
    callback = callback;
    return this;
  }

  IAuthorization build() {
    _type ??= AuthorizationType.useful_jwt;

    switch (_type!) {
      case AuthorizationType.basic_jwt:
        return BasicJwtAuth(_userName, _password, callback: _callback);
      case AuthorizationType.useful_jwt:
        return UsefulJwtAuth(_userName, _password, callback: _callback);
      case AuthorizationType.basic:
        return BasicAuth(_userName, _password, callback: _callback);
    }
  }
}
