import 'package:dio/dio.dart';

import '../authorization_base.dart';

/// Sends a ready-made access token as `Authorization: Bearer <token>`.
///
/// Use it for WordPress.com and Jetpack sites (OAuth2 tokens from
/// `WordpressComOAuth`) or any site whose plugin issues bearer tokens you
/// obtained yourself. The token is never refreshed; build a new client, or
/// call `reconfigure`, when it changes.
///
/// ```dart
/// final client = WordpressClient.forWordpressCom(
///   site: 'example.wordpress.com',
///   bootstrapper: (b) => b
///       .withDefaultAuthorization(BearerTokenAuth(accessToken))
///       .build(),
/// );
/// ```
final class BearerTokenAuth extends IAuthorization {
  /// Creates a [BearerTokenAuth] that sends [token].
  BearerTokenAuth(String token, {super.events})
      : super(userName: '', password: token);

  /// The access token.
  String get token => password;

  @override
  bool get isDefault => token.isEmpty;

  @override
  bool get isValidAuth => token.isNotEmpty;

  @override
  String get scheme => 'Bearer';

  @override
  Future<bool> authorize() async => isValidAuth;

  @override
  Future<bool> isAuthenticated() async => isValidAuth;

  @override
  Future<bool> validate() async => isValidAuth;

  @override
  Future<String?> generateAuthUrl() async =>
      isValidAuth ? '$scheme $token' : null;

  @override
  void clientFactoryProvider(Dio client) {}

  @override
  String toString() => 'BearerTokenAuth(token: <hidden>)';
}
