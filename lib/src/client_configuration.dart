import 'authorization/authorization_base.dart';
import 'utilities/pair.dart';

class BootstrapConfiguration {
  final int? requestTimeout;
  final bool Function(dynamic)? responsePreprocessorDelegate;
  final IAuthorization? defaultAuthorization;
  final String? defaultUserAgent;
  final List<Pair<String, String>>? defaultHeaders;
  final bool? shouldFollowRedirects;
  final int? maxRedirects;
  final bool? useCookies;
  final bool? waitWhileBusy;
  final void Function(String, String?, int?)? statisticsDelegate;

  BootstrapConfiguration({
    this.useCookies,
    this.requestTimeout,
    this.responsePreprocessorDelegate,
    this.defaultAuthorization,
    this.defaultUserAgent,
    this.defaultHeaders,
    this.shouldFollowRedirects,
    this.maxRedirects,
    this.waitWhileBusy,
    this.statisticsDelegate,
  });
}
