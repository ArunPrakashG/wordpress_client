// ignore_for_file: avoid_positional_boolean_parameters

import 'package:dio/dio.dart';

import 'authorization/authorization_base.dart';
import 'authorization/authorization_builder.dart';
import 'client_configuration.dart';
import 'constants.dart';
import 'middleware/wordpress_middleware_base.dart';
import 'utilities/typedefs.dart';

/// A builder class for creating a [BootstrapConfiguration] with a fluent API.
///
/// This class allows for easy configuration of various WordPress client settings
/// through method chaining.
class BootstrapBuilder {
  /// Creates a new [BootstrapBuilder] instance.
  BootstrapBuilder();

  /// Creates a [BootstrapBuilder] instance from an existing [BootstrapConfiguration].
  ///
  /// This constructor initializes the builder with the values from the provided configuration.
  BootstrapBuilder.fromConfiguration(BootstrapConfiguration config) {
    _debugMode = config.enableDebugMode;
    _statisticsDelegate = config.statisticsDelegate;
    _defaultAuthorization = config.defaultAuthorization;
    _defaultUserAgent = config.defaultUserAgent;
    _defaultHeaders = config.defaultHeaders;
    _interceptors = config.interceptors;
    _responsePreprocessorDelegate = config.responsePreprocessorDelegate;
    _defaultMaxRedirects = config.maxRedirects;
    _defaultRequestTimeout = config.receiveTimeout;
    _followRedirects = config.shouldFollowRedirects;
    _middlewares = config.middlewares;
  }
  Duration _defaultRequestTimeout = DEFAULT_REQUEST_TIMEOUT;
  bool Function(dynamic)? _responsePreprocessorDelegate;
  IAuthorization? _defaultAuthorization;
  String? _defaultUserAgent;
  Map<String, dynamic>? _defaultHeaders;
  bool _followRedirects = true;
  int _defaultMaxRedirects = 5;
  StatisticsCallback? _statisticsDelegate;
  List<Interceptor>? _interceptors;
  bool _debugMode = false;
  List<IWordpressMiddleware>? _middlewares;

  /// Enables or disables debug mode.
  ///
  /// When enabled, this attaches a [LogInterceptor] to the [Dio] instance.
  BootstrapBuilder withDebugMode(bool value) {
    _debugMode = value;
    return this;
  }

  /// Adds a single middleware to the configuration.
  BootstrapBuilder withMiddleware(IWordpressMiddleware middleware) {
    _middlewares ??= [];
    _middlewares!.add(middleware);
    return this;
  }

  /// Adds multiple middlewares to the configuration.
  BootstrapBuilder withMiddlewares(Iterable<IWordpressMiddleware> middlewares) {
    _middlewares ??= [];
    _middlewares!.addAll(middlewares);
    return this;
  }

  /// Adds a Dio interceptor to the configuration.
  BootstrapBuilder withDioInterceptor(Interceptor interceptor) {
    _interceptors ??= [];
    _interceptors!.add(interceptor);
    return this;
  }

  /// Sets the statistics delegate for collecting request statistics.
  BootstrapBuilder withStatisticDelegate(StatisticsCallback? delegate) {
    _statisticsDelegate = delegate;
    return this;
  }

  /// Sets the default request timeout.
  BootstrapBuilder withRequestTimeout(Duration timeout) {
    _defaultRequestTimeout = timeout;
    return this;
  }

  /// Sets a response preprocessor function.
  BootstrapBuilder withResponsePreprocessor(
    bool Function(dynamic) preprocessor,
  ) {
    _responsePreprocessorDelegate = preprocessor;
    return this;
  }

  /// Sets the default authorization for requests.
  BootstrapBuilder withDefaultAuthorization(IAuthorization authorization) {
    _defaultAuthorization = authorization;
    return this;
  }

  /// Sets the default authorization using a builder function.
  BootstrapBuilder withDefaultAuthorizationBuilder(
    IAuthorization Function(AuthorizationBuilder) builder,
  ) {
    _defaultAuthorization = builder(AuthorizationBuilder());
    return this;
  }

  /// Sets the default User-Agent header for requests.
  BootstrapBuilder withDefaultUserAgent(String userAgent) {
    _defaultUserAgent = userAgent;
    return this;
  }

  /// Sets default headers for all requests.
  BootstrapBuilder withDefaultHeaders(Map<String, dynamic> headers) {
    _defaultHeaders = headers;
    return this;
  }

  /// Configures whether to follow redirects automatically.
  BootstrapBuilder withFollowRedirects(bool follow) {
    _followRedirects = follow;
    return this;
  }

  /// Sets the maximum number of redirects to follow.
  BootstrapBuilder withMaxRedirects(int maxRedirects) {
    _defaultMaxRedirects = maxRedirects;
    return this;
  }

  /// Builds and returns a [BootstrapConfiguration] instance with the configured settings.
  BootstrapConfiguration build() {
    return BootstrapConfiguration(
      receiveTimeout: _defaultRequestTimeout,
      responsePreprocessorDelegate: _responsePreprocessorDelegate,
      defaultAuthorization: _defaultAuthorization,
      defaultUserAgent: _defaultUserAgent,
      defaultHeaders: _defaultHeaders,
      shouldFollowRedirects: _followRedirects,
      maxRedirects: _defaultMaxRedirects,
      statisticsDelegate: _statisticsDelegate,
      interceptors: _interceptors,
      enableDebugMode: _debugMode,
      middlewares: _middlewares,
    );
  }
}
