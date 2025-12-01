import '../../wordpress_client.dart';

/// Convenience factory helpers for common authorization methods.
///
/// Example:
/// ```dart
/// final client = WordpressClient(
///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
///   bootstrapper: (b) => b
///     .withDefaultAuthorization(
///       WordpressAuth.appPassword(user: 'user', appPassword: 'xxxx-xxxx'),
///     )
///     .build(),
/// );
/// ```
abstract final class WordpressAuth {
  /// Application Password auth (Basic) built into WordPress 5.6+
  static IAuthorization appPassword({
    required String user,
    required String appPassword,
  }) =>
      AppPasswordAuth(userName: user, password: appPassword);

  /// JWT via the Useful Team plugin
  static IAuthorization usefulJwt({
    required String user,
    required String password,
    String? device,
  }) =>
      UsefulJwtAuth(userName: user, password: password, device: device);

  /// JWT via the classic/basic plugin
  static IAuthorization basicJwt({
    required String user,
    required String password,
  }) =>
      BasicJwtAuth(userName: user, password: password);
}
