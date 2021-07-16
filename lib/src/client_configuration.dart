import 'package:wordpress_client/src/utilities/cookie_container.dart';
import 'package:wordpress_client/src/wordpress_authorization.dart';

import 'utilities/pair.dart';

class BootstrapConfiguration {
  final int requestTimeout;
  final bool Function(dynamic) responsePreprocessorDelegate;
  final WordpressAuthorization defaultAuthorization;
  final String defaultUserAgent;
  final List<Pair<String, String>> defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final CookieContainer cookieContainer;

  BootstrapConfiguration({
    this.cookieContainer,
    this.requestTimeout,
    this.responsePreprocessorDelegate,
    this.defaultAuthorization,
    this.defaultUserAgent,
    this.defaultHeaders,
    this.shouldFollowRedirects,
    this.maxRedirects,
  });
}
