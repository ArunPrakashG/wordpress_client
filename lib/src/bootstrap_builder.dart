// ignore_for_file: avoid_positional_boolean_parameters, avoid_returning_this

import 'package:dio/dio.dart';

import 'authorization/authorization_base.dart';
import 'authorization/authorization_builder.dart';
import 'client_configuration.dart';
import 'wordpress_client_base.dart';

class BootstrapBuilder {
  int _defaultRequestTimeout = 60 * 1000; // 60 seconds
  bool Function(dynamic)? _responsePreprocessorDelegate;
  IAuthorization? _defaultAuthorization;
  String? _defaultUserAgent;
  Map<String, String>? _defaultHeaders;
  bool _followRedirects = true;
  int _defaultMaxRedirects = 5;
  bool _useCookies = false;
  bool _waitWhileBusy = false;
  bool _cacheResponses = false;
  String? _cachePath;
  StatisticsCallback? _statisticsDelegate;
  List<Interceptor>? _interceptors;

  BootstrapBuilder withConcurrencyWaitWhileBusy(bool value) {
    _waitWhileBusy = value;
    return this;
  }

  BootstrapBuilder withDioInterceptor(Interceptor interceptor) {
    _interceptors ??= [];
    _interceptors!.add(interceptor);
    return this;
  }

  BootstrapBuilder withStatisticDelegate(
      void Function(String? baseUrl, String endPoint, int requestCount)
          delegate) {
    _statisticsDelegate = delegate;
    return this;
  }

  BootstrapBuilder withResponseCache(bool cacheResponse) {
    _cacheResponses = cacheResponse;
    return this;
  }

  BootstrapBuilder withCachePath(String cachePath) {
    _cachePath = cachePath;
    return this;
  }

  BootstrapBuilder withCookies(bool value) {
    _useCookies = value;
    return this;
  }

  BootstrapBuilder withRequestTimeout(int timeoutInSeconds) {
    _defaultRequestTimeout = timeoutInSeconds * 1000;
    return this;
  }

  BootstrapBuilder withResponsePreprocessor(
      bool Function(dynamic) responsePreprocessor) {
    _responsePreprocessorDelegate = responsePreprocessor;
    return this;
  }

  BootstrapBuilder withDefaultAuthorization(IAuthorization authorization) {
    _defaultAuthorization = authorization;
    return this;
  }

  BootstrapBuilder withDefaultAuthorizationBuilder(
      IAuthorization Function(AuthorizationBuilder) builder) {
    _defaultAuthorization = builder(AuthorizationBuilder());
    return this;
  }

  BootstrapBuilder withDefaultUserAgent(String userAgent) {
    _defaultUserAgent = userAgent;
    return this;
  }

  BootstrapBuilder withDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders = headers;
    return this;
  }

  BootstrapBuilder withFollowRedirects(bool followRedirects) {
    _followRedirects = followRedirects;
    return this;
  }

  BootstrapBuilder withDefaultMaxRedirects(int defaultMaxRedirects) {
    _defaultMaxRedirects = defaultMaxRedirects;
    return this;
  }

  BootstrapConfiguration build() {
    return BootstrapConfiguration(
      useCookies: _useCookies,
      requestTimeout: _defaultRequestTimeout,
      responsePreprocessorDelegate: _responsePreprocessorDelegate,
      defaultAuthorization: _defaultAuthorization,
      defaultUserAgent: _defaultUserAgent,
      defaultHeaders: _defaultHeaders,
      shouldFollowRedirects: _followRedirects,
      maxRedirects: _defaultMaxRedirects,
      statisticsDelegate: _statisticsDelegate,
      waitWhileBusy: _waitWhileBusy,
      cacheResponses: _cacheResponses,
      responseCachePath: _cachePath,
      interceptors: _interceptors,
    );
  }
}
