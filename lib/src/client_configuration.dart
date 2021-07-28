import 'authorization.dart';
import 'utilities/pair.dart';

class BootstrapConfiguration {
  final int requestTimeout;
  final bool Function(dynamic) responsePreprocessorDelegate;
  final Authorization defaultAuthorization;
  final String defaultUserAgent;
  final List<Pair<String, String>> defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final bool useCookies;
  final void Function(String, String, int) statisticsDelegate;

  BootstrapConfiguration({
    this.useCookies,
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
