import 'authorization_container.dart';
import 'utilities/cookie_container.dart';
import 'utilities/pair.dart';

class BootstrapConfiguration {
  final int requestTimeout;
  final bool Function(dynamic) responsePreprocessorDelegate;
  final AuthorizationContainer defaultAuthorization;
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
