import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../wordpress_client.dart';
import 'constants.dart';

@immutable
final class BootstrapConfiguration {
  const BootstrapConfiguration({
    this.receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    this.connectTimeout = DEFAULT_CONNECT_TIMEOUT,
    this.responsePreprocessorDelegate,
    this.defaultAuthorization,
    this.defaultUserAgent,
    this.defaultHeaders,
    this.shouldFollowRedirects = false,
    this.maxRedirects = 5,
    this.statisticsDelegate,
    this.interceptors,
    this.enableDebugMode = false,
    this.middlewares,
  });

  final bool enableDebugMode;
  final Duration receiveTimeout;
  final Duration connectTimeout;
  final bool Function(dynamic)? responsePreprocessorDelegate;
  final IAuthorization? defaultAuthorization;
  final String? defaultUserAgent;
  final Map<String, dynamic>? defaultHeaders;
  final bool shouldFollowRedirects;
  final int maxRedirects;
  final List<Interceptor>? interceptors;
  final StatisticsCallback? statisticsDelegate;
  final List<IWordpressMiddleware>? middlewares;

  @override
  bool operator ==(covariant BootstrapConfiguration other) {
    if (identical(this, other)) {
      return true;
    }
    final collectionEquals = const DeepCollectionEquality().equals;

    return other.enableDebugMode == enableDebugMode &&
        other.receiveTimeout == receiveTimeout &&
        other.responsePreprocessorDelegate == responsePreprocessorDelegate &&
        other.defaultAuthorization == defaultAuthorization &&
        other.defaultUserAgent == defaultUserAgent &&
        collectionEquals(other.defaultHeaders, defaultHeaders) &&
        other.shouldFollowRedirects == shouldFollowRedirects &&
        other.maxRedirects == maxRedirects &&
        collectionEquals(other.interceptors, interceptors) &&
        collectionEquals(other.middlewares, middlewares) &&
        other.connectTimeout == connectTimeout &&
        other.statisticsDelegate == statisticsDelegate;
  }

  @override
  int get hashCode {
    return enableDebugMode.hashCode ^
        receiveTimeout.hashCode ^
        responsePreprocessorDelegate.hashCode ^
        defaultAuthorization.hashCode ^
        defaultUserAgent.hashCode ^
        defaultHeaders.hashCode ^
        shouldFollowRedirects.hashCode ^
        maxRedirects.hashCode ^
        interceptors.hashCode ^
        middlewares.hashCode ^
        connectTimeout.hashCode ^
        statisticsDelegate.hashCode;
  }

  BootstrapConfiguration copyWith({
    bool? enableDebugMode,
    Duration? requestTimeout,
    bool Function(dynamic)? responsePreprocessorDelegate,
    IAuthorization? defaultAuthorization,
    String? defaultUserAgent,
    Map<String, dynamic>? defaultHeaders,
    bool? shouldFollowRedirects,
    int? maxRedirects,
    List<Interceptor>? interceptors,
    bool? synchronized,
    StatisticsCallback? statisticsDelegate,
    List<IWordpressMiddleware>? middlewares,
    Duration? connectTimeout,
  }) {
    return BootstrapConfiguration(
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      receiveTimeout: requestTimeout ?? this.receiveTimeout,
      responsePreprocessorDelegate:
          responsePreprocessorDelegate ?? this.responsePreprocessorDelegate,
      defaultAuthorization: defaultAuthorization ?? this.defaultAuthorization,
      defaultUserAgent: defaultUserAgent ?? this.defaultUserAgent,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      shouldFollowRedirects:
          shouldFollowRedirects ?? this.shouldFollowRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      interceptors: interceptors ?? this.interceptors,
      statisticsDelegate: statisticsDelegate ?? this.statisticsDelegate,
      middlewares: middlewares ?? this.middlewares,
      connectTimeout: connectTimeout ?? this.connectTimeout,
    );
  }
}
