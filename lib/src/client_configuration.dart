import 'authorization.dart';
import 'utilities/cookie_container.dart';
import 'utilities/pair.dart';

class BootstrapConfiguration {
  final int requestTimeout;
  final bool Function(dynamic) responsePreprocessorDelegate;
  final Authorization defaultAuthorization;
  final String defaultUserAgent;
  final List<Pair<String, String>> defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final CookieContainer cookieContainer;
  final void Function(String, String, int) statisticsDelegate;

  BootstrapConfiguration({
    this.cookieContainer,
    this.requestTimeout,
    this.responsePreprocessorDelegate,
    this.defaultAuthorization,
    this.defaultUserAgent,
    this.defaultHeaders,
    this.shouldFollowRedirects,
    this.maxRedirects,
    this.statisticsDelegate,
  });
}
