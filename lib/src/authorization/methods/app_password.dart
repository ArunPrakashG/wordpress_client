import 'package:dio/dio.dart';

import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

/// Authentication using Application Passwords, supported on WordPress installations version 5.6 or higher.
///
/// This class provides a way to authenticate with WordPress using Application Passwords,
/// which is a secure method for third-party applications to access WordPress sites.
///
/// Example usage:
/// ```dart
/// final auth = AppPasswordAuth(
///   userName: 'your_username',
///   password: 'your_app_password',
/// );
///
final class AppPasswordAuth extends IAuthorization {
  /// Creates an instance of [AppPasswordAuth].
  ///
  /// [userName]: The WordPress username.
  /// [password]: The application password generated for this user in WordPress.
  /// [events]: Optional [WordpressEvents] to listen to during the authorization process.
  AppPasswordAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  @override
  Future<bool> authorize() async {
    // Application Passwords don't require an explicit authorization step
    return true;
  }

  @override
  Future<String?> generateAuthUrl() async {
    // Generates the Basic Auth header value
    return '$scheme ${base64Encode('$userName:$password')}';
  }

  @override
  Future<bool> isAuthenticated() async {
    // Application Passwords are always considered authenticated if provided
    return true;
  }

  @override
  bool get isValidAuth =>
      super.password.isNotEmpty && super.userName.isNotEmpty;

  @override
  Future<bool> validate() async {
    // Application Passwords don't require validation
    return true;
  }

  @override
  void clientFactoryProvider(Dio client) {
    // No additional configuration needed for Dio client
  }

  @override
  String get scheme => 'Basic';
}
