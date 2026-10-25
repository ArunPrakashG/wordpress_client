import 'dart:math';

import '../responses/wordpress_discovery_response.dart';
import 'authorization_base.dart';
import 'wordpress_auth.dart';

/// The browser based "Authorize Application" flow of WordPress 5.6+.
///
/// The user approves your app on their own site and WordPress redirects back
/// with a freshly created application password, so the app never sees (or asks
/// for) the account password.
///
/// ```dart
/// final flow = AppPasswordFlow.fromDiscovery(
///   client.discovery,
///   appName: 'My App',
///   successUrl: Uri.parse('myapp://wp-callback'),
///   rejectUrl: Uri.parse('myapp://wp-rejected'),
/// );
///
/// await launchUrl(flow.authorizeUrl);           // open the system browser
/// // ... the app receives the redirect as [callback]:
/// final result = flow.parseCallback(callback);
/// if (result is AppPasswordGranted) {
///   client.reconfigure(
///     bootstrapper: (b) => b.withDefaultAuthorization(result.toAuthorization()).build(),
///   );
/// }
/// ```
final class AppPasswordFlow {
  /// Creates a flow against [authorizationEndpoint].
  ///
  /// [successUrl] receives `site_url`, `user_login` and `password`. It may be
  /// an `https` URL or a custom scheme registered by your app. [rejectUrl]
  /// receives `success=false` when the user declines.
  ///
  /// A random `state` value is added to both URLs and checked again in
  /// [parseCallback], so a callback that did not start from this flow is
  /// rejected.
  AppPasswordFlow({
    required this.authorizationEndpoint,
    required this.appName,
    required this.successUrl,
    this.rejectUrl,
    String? appId,
    String? state,
    this.expectedSite,
  })  : appId = appId ?? _uuid(),
        state = state ?? _token();

  /// Builds a flow from the site's discovery data, which advertises where
  /// the authorization page lives.
  ///
  /// Throws a [StateError] when the site does not support application
  /// passwords.
  factory AppPasswordFlow.fromDiscovery(
    WordpressDiscovery discovery, {
    required String appName,
    required Uri successUrl,
    Uri? rejectUrl,
    String? appId,
  }) {
    final endpoint = discoverEndpoint(discovery);
    if (endpoint == null) {
      throw StateError(
        'The site does not advertise application password authorization.',
      );
    }

    return AppPasswordFlow(
      authorizationEndpoint: endpoint,
      appName: appName,
      successUrl: successUrl,
      rejectUrl: rejectUrl,
      appId: appId,
      expectedSite: Uri.tryParse(discovery.url),
    );
  }

  /// The authorization page advertised by [discovery], or `null`.
  static Uri? discoverEndpoint(WordpressDiscovery discovery) {
    final passwords = discovery.authentication['application-passwords'];
    final endpoints = passwords is Map ? passwords['endpoints'] : null;
    final value = endpoints is Map ? endpoints['authorization'] : null;

    return value is String ? Uri.tryParse(value) : null;
  }

  /// `.../wp-admin/authorize-application.php` of the site.
  final Uri authorizationEndpoint;

  /// Name shown to the user on the approval screen.
  final String appName;

  /// A stable UUID identifying your app; WordPress shows the user which
  /// passwords belong to it.
  final String appId;

  /// Where WordPress sends the user (with the new password) after approval.
  final Uri successUrl;

  /// Where WordPress sends the user after a rejection.
  final Uri? rejectUrl;

  /// Value echoed back through the redirect and verified on return.
  final String state;

  /// When set, a callback whose `site_url` points to another origin is
  /// refused.
  final Uri? expectedSite;

  /// The URL to open in the user's browser.
  Uri get authorizeUrl {
    return authorizationEndpoint.replace(
      queryParameters: {
        ...authorizationEndpoint.queryParameters,
        'app_name': appName,
        'app_id': appId,
        'success_url': _withState(successUrl).toString(),
        if (rejectUrl != null) 'reject_url': _withState(rejectUrl!).toString(),
      },
    );
  }

  /// Interprets the redirect WordPress made to [successUrl] / [rejectUrl].
  ///
  /// Throws a [FormatException] when [callback] is not a response of this
  /// flow (wrong `state`, missing values or an unexpected `site_url`).
  AppPasswordResult parseCallback(Uri callback) {
    final query = callback.queryParameters;

    if (query['state'] != state) {
      throw const FormatException(
        'The callback does not belong to this authorization flow.',
      );
    }

    if (query['success'] == 'false') {
      return const AppPasswordRejected();
    }

    final user = query['user_login'];
    final password = query['password'];
    final site = query['site_url'];

    if (user == null || user.isEmpty || password == null || password.isEmpty) {
      throw const FormatException(
        'The callback carries no user_login / password.',
      );
    }

    final siteUri = site == null ? null : Uri.tryParse(site);
    final expected = expectedSite;
    if (expected != null &&
        siteUri != null &&
        !_sameOrigin(expected, siteUri)) {
      throw FormatException(
        'The callback is for $siteUri but this flow targets $expected.',
      );
    }

    return AppPasswordGranted(
      userLogin: user,
      password: password,
      siteUrl: siteUri ?? expected,
    );
  }

  Uri _withState(Uri url) {
    return url.replace(
      queryParameters: {...url.queryParameters, 'state': state},
    );
  }

  static bool _sameOrigin(Uri a, Uri b) {
    return a.scheme == b.scheme && a.host == b.host && a.port == b.port;
  }

  static String _token() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  static String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

/// Outcome of [AppPasswordFlow.parseCallback].
sealed class AppPasswordResult {
  const AppPasswordResult();
}

/// The user approved the app.
final class AppPasswordGranted extends AppPasswordResult {
  /// Creates a granted result.
  const AppPasswordGranted({
    required this.userLogin,
    required this.password,
    this.siteUrl,
  });

  /// The account the password belongs to.
  final String userLogin;

  /// The new application password (shown only once by WordPress).
  final String password;

  /// The site that issued it.
  final Uri? siteUrl;

  /// Credentials ready for `withDefaultAuthorization`.
  IAuthorization toAuthorization() =>
      WordpressAuth.appPassword(user: userLogin, appPassword: password);

  @override
  String toString() => 'AppPasswordGranted($userLogin)';
}

/// The user declined the request.
final class AppPasswordRejected extends AppPasswordResult {
  /// Creates a rejected result.
  const AppPasswordRejected();
}
