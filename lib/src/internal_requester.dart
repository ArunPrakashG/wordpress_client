part of 'wordpress_client_base.dart';

typedef MiddlwareResponseTransformer = WordpressRawResponse Function(
  MiddlewareRawResponse data,
);

final class InternalRequester extends IRequestExecutor {
  InternalRequester.configure(
    this._baseUrl,
    this._client, [
    this._configuration = const BootstrapConfiguration(),
  ]) {
    configure(_configuration);
  }

  final Dio _client;
  Uri? _baseUrl;
  IAuthorization? _defaultAuthorization;
  static final Map<String, int> _endPointStatistics = <String, int>{};
  static StatisticsCallback? _statisticsCallback;
  bool _isDebugMode = false;
  final BootstrapConfiguration _configuration;

  /// The request base url.
  ///
  /// This is the base url used for all requests.
  ///
  /// Basically, Base URL + Path
  @override
  Uri get baseUrl {
    if (_baseUrl == null) {
      throw StateError(
        'Base URL is not set. Did you forget to call `initialize` method?',
      );
    }

    return _baseUrl!;
  }

  bool get hasBaseURL => _baseUrl != null;

  bool get hasDefaultAuthorization =>
      _defaultAuthorization != null && !_defaultAuthorization!.isDefault;

  @override
  List<IWordpressMiddleware> get middlewares =>
      _configuration.middlewares ?? [];

  void _setBaseUrl(Uri url) {
    if (!url.isAbsolute) {
      throw ArgumentError(
        'The provided url is relative. Base URLs should always be an absolute URL.',
        'baseUrl',
      );
    }

    if (!isValidPortNumber(url.port)) {
      throw ArgumentError(
        'The provided port number is invalid. Port numbers should be between 1 and 65535.',
        'baseUrl',
      );
    }

    if (!isValidRestApiUrl(url)) {
      throw ArgumentError(
        'The provided url is invalid. The REST API path should be appended to the base URL.',
        'baseUrl',
      );
    }

    _baseUrl = url;
    _client.options.baseUrl = url.toString();
  }

  @override
  void configure(BootstrapConfiguration configuration) {
    _isDebugMode = configuration.enableDebugMode;

    if (configuration.defaultAuthorization != null &&
        !configuration.defaultAuthorization!.isDefault) {
      _defaultAuthorization = configuration.defaultAuthorization;
    }

    if (configuration.statisticsDelegate != null) {
      _statisticsCallback = configuration.statisticsDelegate;
    }

    if (configuration.defaultUserAgent != null) {
      _client.options.headers['User-Agent'] = configuration.defaultUserAgent;
    }

    if (configuration.defaultHeaders != null &&
        configuration.defaultHeaders!.isNotEmpty) {
      for (final header in configuration.defaultHeaders!.entries) {
        _client.options.headers[header.key] = header.value;
      }
    }

    _client.options.connectTimeout = configuration.connectTimeout;
    _client.options.receiveTimeout = configuration.receiveTimeout;
    _client.options.followRedirects = configuration.shouldFollowRedirects;
    _client.options.maxRedirects = configuration.maxRedirects;

    if (_baseUrl != null) {
      _client.options.baseUrl = baseUrl.toString();
    }

    if (configuration.enableDebugMode &&
        !_client.interceptors.any((i) => i is LogInterceptor)) {
      _client.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    if (configuration.interceptors != null &&
        configuration.interceptors!.isNotEmpty) {
      for (final interceptor in configuration.interceptors!) {
        if (_client.interceptors.contains(interceptor)) {
          continue;
        }

        _client.interceptors.add(interceptor);
      }
    }
  }

  void _removeDefaultAuthorization() {
    _defaultAuthorization = null;
  }

  @override
  Future<WordpressRawResponse> execute(WordpressRequest request) async {
    if (_client.options.baseUrl.isEmpty) {
      throw StateError(
        'Base URL is not set. Did you forget to call `reconfigure` method?',
      );
    }

    final requestHeaders = request.headers ?? <String, dynamic>{};

    // If the request requires authorization, we need to check if the default authorization is set.
    // If it is, we need to check if the default authorization is valid.
    if (request.requireAuth) {
      final authorizer = () {
        if (request.authorization != null &&
            !request.authorization!.isDefault) {
          return request.authorization;
        }

        return _defaultAuthorization;
      }();

      if (authorizer == null) {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.authorizationModuleNotFound.index,
          message: 'No valid authorization module found.',
        );
      }

      final authResult = await _processAuthorization(
        auth: authorizer,
      );

      if (authResult == null) {
        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType
              .authorizationFailedWithProvidedCredentials.index,
          message: 'Failed to authorize with the provided authorization.',
        );
      }

      requestHeaders[authResult.key] = authResult.value;
    }

    // Generate the request URL.
    final requestUrl = () {
      if (request.url.isAbsolute) {
        return request.url.uri.replace(host: baseUrl.host).toString();
      }

      return join(baseUrl.toString(), request.url.toString());
    }();

    _triggerStatistics(requestUrl);

    // Trigger the onExecute middleware event and returns the result.
    // If the result is not null, we return the result.
    // This is used if the user already has some sort of custom cache implementation.
    final middlewareResult = await guardAsync(
      function: () async {
        return _executeMiddlewareEvent(
          request: request,
          transformer: (data) {
            final headers = <String, dynamic>{
              MIDDLEWARE_HEADER_KEY: true,
            };

            headers.addAllIfNotNull(data.headers);

            return WordpressRawResponse(
              data: data,
              code: data.statusCode,
              headers: headers,
              requestHeaders: requestHeaders,
              extra: data.extra ?? <String, dynamic>{},
              message:
                  data.message ?? 'Middleware event executed successfully.',
            );
          },
        );
      },
      onError: (error, stackTrace) async {
        return WordpressRawResponse(
          data: null,
          requestHeaders: requestHeaders,
          code: -RequestErrorType.middlewareExecutionFailed.index,
          message: 'Middleware execution failed.',
        );
      },
    );

    if (middlewareResult != null &&
        middlewareResult.code !=
            -RequestErrorType.middlewareExecutionFailed.index) {
      return middlewareResult;
    }

    final watch = Stopwatch();

    Future<Response<T>> run<T>() async {
      watch.start();

      try {
        return _client.request<T>(
          requestUrl,
          data: request.body,
          cancelToken: request.cancelToken,
          queryParameters: request.queryParameters,
          onSendProgress: request.events?.onSend,
          onReceiveProgress: request.events?.onReceive,
          options: Options(
            receiveDataWhenStatusError: true,
            validateStatus: (status) => true,
            method: request.method.name,
            sendTimeout: request.body != null ? request.sendTimeout : null,
            receiveTimeout: request.receiveTimeout,
            headers: requestHeaders,
          ),
        );
      } catch (e) {
        rethrow;
      } finally {
        watch.stop();
      }
    }

    final response = await run<dynamic>();

    final statusCode =
        response.statusCode ?? -RequestErrorType.invalidStatusCode.index;
    request.events?.onResponse?.call(response.data);

    return WordpressRawResponse(
      data: response.data,
      code: statusCode,
      headers: response.headers.getHeaderMap(),
      duration: watch.elapsed,
      requestHeaders: response.requestOptions.headers,
      extra: response.extra,
      message: response.statusMessage,
    );
  }

  Future<WordpressRawResponse?> _executeMiddlewareEvent({
    required WordpressRequest request,
    required MiddlwareResponseTransformer transformer,
  }) async {
    for (final middleware in middlewares) {
      final result = await middleware.onExecute(request);

      if (result.hasData) {
        return transformer(result);
      }
    }

    return null;
  }

  Dio _createAuthDioClient() {
    final client = Dio(
      BaseOptions(
        baseUrl: baseUrl.toString(),
        headers: _client.options.headers,
        connectTimeout: _client.options.connectTimeout,
        receiveTimeout: _client.options.receiveTimeout,
        sendTimeout: _client.options.sendTimeout,
        followRedirects: _client.options.followRedirects,
        maxRedirects: _client.options.maxRedirects,
      ),
    );

    if (_isDebugMode) {
      client.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    return client;
  }

  Future<WordpressResponse<WordpressDiscovery>> discover() async {
    final request = WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.absolute(
        Uri.parse(
          joinAll([
            baseUrl.origin,
            baseUrl.pathSegments.first,
          ]),
        ),
      ),
    );

    final response = await execute(request);

    return response.asResponse<WordpressDiscovery>(
      // ignore: unnecessary_lambdas
      decoder: (instance) => WordpressDiscovery.fromJson(instance),
    );
  }

  Future<({String key, String value})?> _processAuthorization({
    required IAuthorization auth,
  }) async {
    if (await auth.isAuthenticated()) {
      return (key: auth.headerKey, value: (await auth.generateAuthUrl())!);
    }

    auth.clientFactoryProvider(_createAuthDioClient());

    await auth.initialize(baseUrl: baseUrl);

    if (await auth.authorize() && await auth.isAuthenticated()) {
      final authUrl = await auth.generateAuthUrl();

      if (authUrl != null && await auth.isAuthenticated()) {
        return (key: auth.headerKey, value: authUrl);
      }
    }

    return null;
  }

  void _triggerStatistics(String requestUrl) {
    _endPointStatistics[requestUrl] =
        (_endPointStatistics[requestUrl] ?? 0) + 1;

    if (_statisticsCallback == null) {
      return;
    }

    _statisticsCallback!(
      requestUrl,
      _endPointStatistics[requestUrl]!,
    );
  }
}
