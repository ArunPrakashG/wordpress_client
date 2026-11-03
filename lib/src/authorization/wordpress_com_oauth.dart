import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';

/// What the WordPress.com authorize screen should return.
enum WordpressComResponseType {
  /// An authorization code, exchanged for a token on a server with
  /// [WordpressComOAuth.exchangeCode] (needs the client secret).
  code,

  /// The token itself, in the redirect's fragment. For apps that cannot keep
  /// a client secret; read it with [WordpressComOAuth.tokenFromRedirect].
  token,
}

/// An OAuth2 access token issued by WordPress.com.
@immutable
final class WordpressComToken {
  const WordpressComToken({
    required this.accessToken,
    this.tokenType = 'bearer',
    this.blogId,
    this.blogUrl,
    this.scope,
    this.expiresIn,
  });

  /// Reads the JSON answer of the token endpoint, or the fields of an
  /// implicit-flow redirect.
  factory WordpressComToken.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_in'];

    return WordpressComToken(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      blogId: json['blog_id']?.toString() ?? json['site_id']?.toString(),
      blogUrl: json['blog_url'] as String?,
      scope: json['scope'] as String?,
      expiresIn: switch (expires) {
        final int seconds => Duration(seconds: seconds),
        final String seconds when int.tryParse(seconds) != null =>
          Duration(seconds: int.parse(seconds)),
        _ => null,
      },
    );
  }

  /// The token to send as `Authorization: Bearer <token>`.
  final String accessToken;

  /// Always `bearer` on WordPress.com.
  final String tokenType;

  /// The site the token was granted for, when it is limited to one.
  final String? blogId;

  /// The URL of that site.
  final String? blogUrl;

  /// The granted scope, e.g. `global` for access to every site of the user.
  final String? scope;

  /// How long an implicit-flow token is valid. Null for codes exchanged on a
  /// server, whose tokens do not expire until revoked.
  final Duration? expiresIn;

  @override
  String toString() =>
      'WordpressComToken(blogId: $blogId, scope: $scope, accessToken: <hidden>)';
}

/// Helpers for the WordPress.com OAuth2 flow, used by WordPress.com and
/// Jetpack connected sites.
///
/// Register an app at https://developer.wordpress.com/apps/ to get a client
/// id, then:
///
/// ```dart
/// final url = WordpressComOAuth.authorizeUrl(
///   clientId: '12345',
///   redirectUri: Uri.parse('myapp://oauth'),
///   responseType: WordpressComResponseType.token,
/// );
/// // Open url in a browser, then when the app is opened on the redirect:
/// final token = WordpressComOAuth.tokenFromRedirect(redirect);
/// final client = WordpressClient.forWordpressCom(
///   site: 'example.wordpress.com',
///   accessToken: token!.accessToken,
/// );
/// ```
abstract final class WordpressComOAuth {
  /// The authorize screen.
  static final Uri authorizeEndpoint =
      Uri.https(wordpressComApiHost, '/oauth2/authorize');

  /// The endpoint that exchanges a code for a token.
  static final Uri tokenEndpoint =
      Uri.https(wordpressComApiHost, '/oauth2/token');

  /// The URL to send the user to so they can grant access.
  ///
  /// [blog] preselects a site (its URL or ID). [scope] is space separated;
  /// leave it out for access to one site, or use `global` for all of them.
  /// [state] is sent back unchanged on the redirect; use a random value and
  /// check it to block forged redirects.
  static Uri authorizeUrl({
    required String clientId,
    required Uri redirectUri,
    WordpressComResponseType responseType = WordpressComResponseType.code,
    String? blog,
    String? scope,
    String? state,
  }) {
    return authorizeEndpoint.replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'response_type': responseType.name,
        if (blog != null) 'blog': blog,
        if (scope != null) 'scope': scope,
        if (state != null) 'state': state,
      },
    );
  }

  /// Reads the token from an implicit-flow redirect
  /// (`myapp://oauth#access_token=...&expires_in=...`).
  ///
  /// Returns null when the redirect carries no token, for example because
  /// the user denied access, or when [expectedState] is given and differs.
  static WordpressComToken? tokenFromRedirect(
    Uri redirect, {
    String? expectedState,
  }) {
    final fields = redirect.fragment.isEmpty
        ? redirect.queryParameters
        : Uri.splitQueryString(redirect.fragment);

    if (expectedState != null && fields['state'] != expectedState) {
      return null;
    }

    final token = fields['access_token'];
    if (token == null || token.isEmpty) {
      return null;
    }

    return WordpressComToken.fromJson(fields);
  }

  /// Exchanges the [code] of an authorization-code redirect for a token.
  ///
  /// Needs the app's client secret, so run this on a server you control, not
  /// in a shipped app. Throws a [DioException] when WordPress.com refuses
  /// the exchange (its `error_description` is in the response).
  static Future<WordpressComToken> exchangeCode({
    required String clientId,
    required String clientSecret,
    required Uri redirectUri,
    required String code,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();

    try {
      final response = await client.postUri<Map<String, dynamic>>(
        tokenEndpoint,
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri.toString(),
          'code': code,
          'grant_type': 'authorization_code',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return WordpressComToken.fromJson(response.data!);
    } finally {
      if (dio == null) {
        client.close();
      }
    }
  }
}
