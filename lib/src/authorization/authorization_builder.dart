// ignore_for_file: avoid_returning_this

import '../enums.dart';
import '../utilities/wordpress_events.dart';
import 'authorization_base.dart';
import 'methods/app_password.dart';
import 'methods/basic_jwt.dart';
import 'methods/useful_jwt.dart';

/// Creates a new instance of [AuthorizationBuilder].
final class AuthorizationBuilder {
  String _userName = '';
  String _password = '';
  AuthorizationType? _type;
  WordpressEvents? _events;

  AuthorizationBuilder withUserName(String userName) {
    _userName = userName;
    return this;
  }

  AuthorizationBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  AuthorizationBuilder withType(AuthorizationType type) {
    _type = type;
    return this;
  }

  AuthorizationBuilder withEvents(WordpressEvents events) {
    _events = events;
    return this;
  }

  /// Builds the authorization instance.
  IAuthorization build() {
    _type ??= AuthorizationType.useful_jwt;

    switch (_type!) {
      case AuthorizationType.basic_jwt:
        return BasicJwtAuth(
          userName: _userName,
          password: _password,
          events: _events,
        );
      case AuthorizationType.useful_jwt:
        return UsefulJwtAuth(
          userName: _userName,
          password: _password,
          events: _events,
        );
      case AuthorizationType.basic:
        return AppPasswordAuth(
          userName: _userName,
          password: _password,
          events: _events,
        );
    }
  }
}
