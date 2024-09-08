import 'dart:async';

import 'package:dio/dio.dart';

import '../../utilities/helpers.dart';
import '../authorization_base.dart';

/// The most basic authentication system using username and password.
///
/// This class implements Basic Authentication for WordPress API, based on
/// the https://github.com/WP-API/Basic-Auth WordPress plugin.
///
/// WARNING: This method should only be used for testing purposes as it is not secure
/// for production environments.
///
/// Example usage:
/// ```dart
/// final auth = BasicAuth(userName: 'myuser', password: 'mypassword');
/// final isAuthorized = await auth.authorize();
/// if (isAuthorized) {
///   final authHeader = await auth.generateAuthUrl();
///   // Use authHeader in your API requests
/// }
/// ```
///
/// @deprecated Use AppPasswordAuth instead for more secure authentication.
@Deprecated('Use AppPasswordAuth instead')
final class BasicAuth extends IAuthorization {
  /// Creates a new BasicAuth instance.
  ///
  /// [userName] and [password] are required parameters.
  /// [events] is an optional parameter for authentication events.
  ///
  /// @deprecated Use AppPasswordAuth instead for more secure authentication.
  @Deprecated('Use AppPasswordAuth instead')
  BasicAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  /// Authorizes the user. Always returns true for BasicAuth.
  ///
  /// This method is part of the IAuthorization interface but doesn't perform
  /// any actual authorization for BasicAuth.
  @override
  Future<bool> authorize() async {
    return true;
  }

  /// Generates the authorization header value.
  ///
  /// Returns a Future<String> containing the Basic Auth header value.
  /// The returned string is in the format: "Basic base64EncodedCredentials"
  @override
  Future<String?> generateAuthUrl() async {
    return '$scheme ${base64Encode('$userName:$password')}';
  }

  /// Checks if the user is authenticated. Always returns true for BasicAuth.
  ///
  /// This method is part of the IAuthorization interface but doesn't perform
  /// any actual authentication check for BasicAuth.
  @override
  Future<bool> isAuthenticated() async {
    return true;
  }

  /// Indicates whether the authentication is valid. Always true for BasicAuth.
  @override
  bool get isValidAuth => true;

  /// Validates the authentication. Always returns true for BasicAuth.
  ///
  /// This method is part of the IAuthorization interface but doesn't perform
  /// any actual validation for BasicAuth.
  @override
  Future<bool> validate() async {
    return true;
  }

  /// Provides a way to modify the Dio client. Not used in BasicAuth.
  ///
  /// This method is part of the IAuthorization interface but doesn't perform
  /// any modifications to the Dio client for BasicAuth.
  @override
  void clientFactoryProvider(Dio client) {}

  /// The authentication scheme used. Returns 'Basic' for BasicAuth.
  @override
  String get scheme => 'Basic';
}
