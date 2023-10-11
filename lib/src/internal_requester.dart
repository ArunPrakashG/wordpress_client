part of 'wordpress_client_base.dart';

final class InternalRequester extends IRequestExecutor {
  InternalRequester.configure(
    this._baseUrl, [
    this._configuration = const BootstrapConfiguration(),
  ]) {
    configure(_configuration);
  }

  final Dio _client = Dio();

  final Uri _baseUrl;
  final sync.Lock _syncLock = sync.Lock();
  IAuthorization? _defaultAuthorization;
  static final Map<String, int> _endPointStatistics = <String, int>{};
  static StatisticsCallback? _statisticsCallback;
  bool _synchronized = false;
  bool _isDebugMode = false;
  final BootstrapConfiguration _configuration;

  /// The request base url.
  ///
  /// This is the base url used for all requests.
  ///
  /// Basically, Base URL + Path
  @override
  Uri get baseUrl => _baseUrl;

  bool get hasDefaultAuthorization =>
      _defaultAuthorization != null && !_defaultAuthorization!.isDefault;

  @override
  void configure(BootstrapConfiguration configuration) {
    _synchronized = configuration.synchronized;
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

    _client.options.connectTimeout = configuration.requestTimeout;
    _client.options.receiveTimeout = configuration.requestTimeout;
    _client.options.followRedirects = configuration.shouldFollowRedirects;
    _client.options.maxRedirects = configuration.maxRedirects;
    _client.options.baseUrl = _baseUrl.toString();

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
    final headers = request.headers ?? <String, dynamic>{};

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

      headers[authResult.key] = authResult.value;
    }

    final requestUrl = () {
      if (request.url.isAbsolute) {
        return request.url.uri.replace(host: baseUrl.host).toString();
      }

      return join(baseUrl.toString(), request.url.toString());
    }();

    _triggerStatistics(requestUrl);

    final watch = Stopwatch();

    Future<Response<dynamic>> run() async {
      watch.start();

      try {
        return _client.request<dynamic>(
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
            sendTimeout: request.sendTimeout,
            receiveTimeout: request.receiveTimeout,
            headers: headers,
          ),
        );
      } finally {
        watch.stop();
      }
    }

    final response =
        _synchronized ? await _syncLock.synchronized(run) : await run();

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

  Dio _createDioClient() {
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

  Future<WordpressDiscovery?> discover() async {
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

    return response
        .asResponse<WordpressDiscovery>(
          // ignore: unnecessary_lambdas
          decoder: (instance) => WordpressDiscovery.fromJson(instance),
        )
        .dataOrNull();
  }

  Future<({String key, String value})?> _processAuthorization({
    required IAuthorization auth,
  }) async {
    if (await auth.isAuthenticated()) {
      return (key: auth.headerKey, value: (await auth.generateAuthUrl())!);
    }

    auth.clientFactoryProvider(_createDioClient());

    await auth.initialize(baseUrl: _baseUrl);

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
