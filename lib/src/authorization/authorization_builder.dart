// ignore_for_file: avoid_returning_this

import '../enums.dart';
import '../utilities/wordpress_events.dart';
import 'authorization_base.dart';
import 'methods/app_password.dart';
import 'methods/basic_jwt.dart';
import 'methods/useful_jwt.dart';

/// Creates a new instance of [AuthorizationBuilder].
///
/// This class uses the builder pattern to construct an authorization instance.
/// Use the various 'with' methods to set the required parameters, then call
/// [build] to create the authorization object.
///
/// Example usage:
/// ```dart
/// final auth = AuthorizationBuilder()
///   .withUserName('myusername')
///   .withPassword('mypassword')
///   .withType(AuthorizationType.useful_jwt)
///   .build();
/// ```
final class AuthorizationBuilder {
  String _userName = '';
  String _password = '';
  AuthorizationType? _type;
  WordpressEvents? _events;

  /// Sets the username for the authorization.
  ///
  /// Example:
  /// ```dart
  /// builder.withUserName('myusername');
  /// ```
  AuthorizationBuilder withUserName(String userName) {
    _userName = userName;
    return this;
  }

  /// Sets the password for the authorization.
  ///
  /// Example:
  /// ```dart
  /// builder.withPassword('mypassword');
  /// ```
  AuthorizationBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  /// Sets the authorization type.
  ///
  /// If not set, it defaults to [AuthorizationType.useful_jwt].
  ///
  /// Example:
  /// ```dart
  /// builder.withType(AuthorizationType.basic_jwt);
  /// ```
  AuthorizationBuilder withType(AuthorizationType type) {
    _type = type;
    return this;
  }

  /// Sets the WordPress events for the authorization.
  ///
  /// This is optional and can be used to handle specific WordPress events.
  ///
  /// Example:
  /// ```dart
  /// builder.withEvents(myWordPressEvents);
  /// ```
  AuthorizationBuilder withEvents(WordpressEvents events) {
    _events = events;
    return this;
  }

  /// Builds and returns the authorization instance based on the set parameters.
  ///
  /// If no type is specified, it defaults to [AuthorizationType.useful_jwt].
  ///
  /// Example:
  /// ```dart
  /// final auth = builder.build();
  /// ```
  ///
  /// Returns an instance of [IAuthorization] which can be one of:
  /// - [BasicJwtAuth]
  /// - [UsefulJwtAuth]
  /// - [AppPasswordAuth]
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
