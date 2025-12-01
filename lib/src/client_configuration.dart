import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../wordpress_client.dart';
import 'constants.dart';

/// Configuration class for bootstrapping the WordPress client.
///
/// This class provides a fluent API for setting up various configuration options
/// for the WordPress client, including timeouts, authorization, headers, and more.
@immutable
final class BootstrapConfiguration {
  /// Creates a new instance of [BootstrapConfiguration] with default or specified values.
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

  /// Enables or disables debug mode.
  final bool enableDebugMode;

  /// The timeout duration for receiving a response.
  final Duration receiveTimeout;

  /// The timeout duration for establishing a connection.
  final Duration connectTimeout;

  /// A function to preprocess the response before it's handled by the client.
  final bool Function(dynamic)? responsePreprocessorDelegate;

  /// The default authorization to use for requests.
  final IAuthorization? defaultAuthorization;

  /// The default User-Agent header to use for requests.
  final String? defaultUserAgent;

  /// Default headers to include in all requests.
  final Map<String, dynamic>? defaultHeaders;

  /// Whether to follow redirects automatically.
  final bool shouldFollowRedirects;

  /// The maximum number of redirects to follow.
  final int maxRedirects;

  /// A list of interceptors to use for requests.
  final List<Interceptor>? interceptors;

  /// A callback for collecting statistics about requests.
  final StatisticsCallback? statisticsDelegate;

  /// A list of middlewares to apply to requests.
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
    return Object.hash(
      enableDebugMode,
      receiveTimeout,
      responsePreprocessorDelegate,
      defaultAuthorization,
      defaultUserAgent,
      defaultHeaders,
      shouldFollowRedirects,
      maxRedirects,
      interceptors,
      middlewares,
      connectTimeout,
      statisticsDelegate,
    );
  }

  /// Creates a copy of this configuration with the given fields replaced with new values.
  BootstrapConfiguration copyWith({
    bool? enableDebugMode,
    Duration? receiveTimeout,
    bool Function(dynamic)? responsePreprocessorDelegate,
    IAuthorization? defaultAuthorization,
    String? defaultUserAgent,
    Map<String, dynamic>? defaultHeaders,
    bool? shouldFollowRedirects,
    int? maxRedirects,
    List<Interceptor>? interceptors,
    StatisticsCallback? statisticsDelegate,
    List<IWordpressMiddleware>? middlewares,
    Duration? connectTimeout,
  }) {
    return BootstrapConfiguration(
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
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
