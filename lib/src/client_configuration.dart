import 'package:dio/dio.dart';

import 'constants.dart';
import 'wordpress_client_base.dart';

class BootstrapConfiguration {
  const BootstrapConfiguration({
    this.useCookies = false,
    this.requestTimeout = kDefaultRequestTimeout,
    this.responsePreprocessorDelegate,
    this.defaultAuthorization,
    this.defaultUserAgent,
    this.defaultHeaders,
    this.shouldFollowRedirects = false,
    this.maxRedirects = 5,
    this.waitWhileBusy = false,
    this.statisticsDelegate,
    this.cacheResponses = false,
    this.responseCachePath,
    this.interceptors,
  });

  final int requestTimeout;
  final bool Function(dynamic)? responsePreprocessorDelegate;
  final IAuthorization? defaultAuthorization;
  final String? defaultUserAgent;
  final Map<String, String>? defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final bool useCookies;
  final List<Interceptor>? interceptors;
  final bool waitWhileBusy;
  final bool cacheResponses;
  final String? responseCachePath;
  final StatisticsCallback? statisticsDelegate;
}
