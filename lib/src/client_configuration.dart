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
    this.synchronized = false,
    this.statisticsDelegate,
    this.interceptors,
    this.enableDebugMode = false,
  });

  final bool enableDebugMode;
  final Duration requestTimeout;
  final bool Function(dynamic)? responsePreprocessorDelegate;
  final IAuthorization? defaultAuthorization;
  final String? defaultUserAgent;
  final Map<String, String>? defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final bool useCookies;
  final List<Interceptor>? interceptors;
  final bool synchronized;
  final StatisticsCallback? statisticsDelegate;
}
