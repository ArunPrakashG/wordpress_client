import 'package:wordpress_client/src/authorization_builder.dart';

import '../authorization.dart';
import '../client_configuration.dart';
import '../utilities/cookie_container.dart';
import '../utilities/pair.dart';

class BootstrapBuilder {
  int _defaultRequestTimeout = 60 * 1000; // 60 seconds
  bool Function(dynamic) _responsePreprocessorDelegate;
  Authorization _defaultAuthorization;
  String _defaultUserAgent;
  List<Pair<String, String>> _defaultHeaders;
  bool _followRedirects = true;
  int _defaultMaxRedirects = 5;
  CookieContainer _cookieContainer;

  BootstrapBuilder withCookieContainer(CookieContainer container) {
    _cookieContainer = container;
    return this;
  }

  BootstrapBuilder withRequestTimeout(int timeoutInSeconds) {
    _defaultRequestTimeout = timeoutInSeconds * 1000;
    return this;
  }

  BootstrapBuilder withResponsePreprocessor(bool Function(dynamic) responsePreprocessor) {
    _responsePreprocessorDelegate = responsePreprocessor;
    return this;
  }

  BootstrapBuilder withDefaultAuthorization(Authorization Function(AuthorizationBuilder) authorizationBuilder) {
    _defaultAuthorization = authorizationBuilder(AuthorizationBuilder());
    return this;
  }

  BootstrapBuilder withDefaultUserAgent(String userAgent) {
    _defaultUserAgent = userAgent;
    return this;
  }

  BootstrapBuilder withDefaultHeaders(List<Pair<String, String>> headers) {
    _defaultHeaders ??= [];
    _defaultHeaders.addAll(headers);
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
      cookieContainer: _cookieContainer,
      requestTimeout: _defaultRequestTimeout,
      responsePreprocessorDelegate: _responsePreprocessorDelegate,
      defaultAuthorization: _defaultAuthorization,
      defaultUserAgent: _defaultUserAgent,
      defaultHeaders: _defaultHeaders,
      shouldFollowRedirects: _followRedirects,
      maxRedirects: _defaultMaxRedirects,
    );
  }
}
