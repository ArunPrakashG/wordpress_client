part of 'wordpress_client_base.dart';

typedef StatisticsCallback = void Function(
  String baseUrl,
  String endpoint,
  int requestCount,
);

class InternalRequester {
  InternalRequester({
    required String baseUrl,
    required String path,
    BootstrapConfiguration configuration = const BootstrapConfiguration(),
  }) {
    _baseUrl = parseUrl(baseUrl, path);
    configure(configuration);
  }

  final Dio _client = Dio();
  late final String _baseUrl;
  IAuthorization? _defaultAuthorization;
  static final Map<String, int> _endPointStatistics = <String, int>{};
  static StatisticsCallback? _statisticsCallback;
  bool _isBusy = false;
  bool _singleRequestAtATimeMode = false;

  bool get isBusy => _isBusy;

  void configure(BootstrapConfiguration configuration) {
    _singleRequestAtATimeMode = configuration.waitWhileBusy;

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
    _client.options.baseUrl = _baseUrl;

    if (configuration.useCookies) {
      _client.interceptors.add(CookieManager(CookieJar()));
    }

    if (configuration.cacheResponses &&
        configuration.responseCachePath != null) {
      _client.interceptors.add(
        DioCacheInterceptor(
          options: CacheOptions(
            store: FileCacheStore(configuration.responseCachePath!),
            hitCacheOnErrorExcept: [401, 403],
            maxStale: const Duration(days: 7),
          ),
        ),
      );
    }

    if (configuration.interceptors != null &&
        configuration.interceptors!.isNotEmpty) {
      _client.interceptors.addAll(configuration.interceptors!);
    }
  }

  Future<void> waitWhileBusy() async {
    if (!_singleRequestAtATimeMode) {
      return;
    }

    while (_isBusy) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  void _removeDefaultAuthorization() {
    _defaultAuthorization = null;
  }

  bool _validateResponse<T>(WordpressRequest request, T? response) {
    if (!request.shouldValidateResponse) {
      return true;
    }

    return request.responseValidationCallback!(response);
  }

  Future<WordpressResponse<T?>> createRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw const RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      _invokeStatisticsCallback(
        Uri.tryParse(parseUrl(_baseUrl, request.endpoint)).toString(),
        request.endpoint,
      );

      final dioResponse = await _client.request<dynamic>(
        request.endpoint.startsWith('/')
            ? request.endpoint
            : '/${request.endpoint}',
        data: request.body,
        cancelToken: request.cancelToken,
        queryParameters: request.queryParams,
        onSendProgress: request.callback?.onSendProgress,
        onReceiveProgress: request.callback?.onReceiveProgress,
        options: Options(
          method: request.method.name,
          sendTimeout: request.sendTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
      );

      watch.stop();

      if (dioResponse.statusCode == null) {
        throw const NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<T?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return WordpressResponse<T?>.failed(
          response,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        requestDuration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return WordpressResponse<T?>.failed(
        null,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<WordpressResponse<T?>> deleteRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw const RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      _invokeStatisticsCallback(
        Uri.tryParse(parseUrl(_baseUrl, request.endpoint)).toString(),
        request.endpoint,
      );

      final dioResponse = await _client.request<dynamic>(
        request.endpoint.startsWith('/')
            ? request.endpoint
            : '/${request.endpoint}',
        data: request.body,
        cancelToken: request.cancelToken,
        queryParameters: request.queryParams,
        onSendProgress: request.callback?.onSendProgress,
        onReceiveProgress: request.callback?.onReceiveProgress,
        options: Options(
          method: request.method.name,
          sendTimeout: request.sendTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
      );

      watch.stop();

      if (dioResponse.statusCode == null) {
        throw const NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<T?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      if (!_validateResponse<T>(request, null)) {
        return WordpressResponse<T?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<T?>(
        null,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        requestDuration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return WordpressResponse<T?>.failed(
        null,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<WordpressResponse<List<T>?>> listRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw const RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      final dioResponse = await _client.request<dynamic>(
        request.endpoint.startsWith('/')
            ? request.endpoint
            : '/${request.endpoint}',
        data: request.body,
        cancelToken: request.cancelToken,
        queryParameters: request.queryParams,
        onSendProgress: request.callback?.onSendProgress,
        onReceiveProgress: request.callback?.onReceiveProgress,
        options: Options(
          method: request.method.name,
          sendTimeout: request.sendTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
      );

      watch.stop();

      _invokeStatisticsCallback(
        dioResponse.requestOptions.uri.toString(),
        request.endpoint,
      );

      if (dioResponse.statusCode == null) {
        throw const NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<List<T>?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      if (dioResponse.data is! Iterable<dynamic>) {
        return WordpressResponse<List<T>?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          message: 'Response is not a list.',
        );
      }

      final response = (dioResponse.data as Iterable<dynamic>)
          .map<T>(deserialize<T>)
          .toList();

      if (!_validateResponse<List<T>>(request, response)) {
        return WordpressResponse<List<T>?>.failed(
          response,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<List<T>>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        requestDuration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e);
      }

      return WordpressResponse<List<T>?>.failed(
        null,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<WordpressResponse<T?>> retriveRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw const RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      _invokeStatisticsCallback(
        Uri.tryParse(parseUrl(_baseUrl, request.endpoint)).toString(),
        request.endpoint,
      );

      final dioResponse = await _client.request<dynamic>(
        request.endpoint.startsWith('/')
            ? request.endpoint
            : '/${request.endpoint}',
        data: request.body,
        cancelToken: request.cancelToken,
        queryParameters: request.queryParams,
        onSendProgress: request.callback?.onSendProgress,
        onReceiveProgress: request.callback?.onReceiveProgress,
        options: Options(
          method: request.method.name,
          sendTimeout: request.sendTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
      );

      watch.stop();

      if (dioResponse.statusCode == null) {
        throw const NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<T?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return WordpressResponse<T?>.failed(
          response,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        requestDuration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return WordpressResponse<T?>.failed(
        null,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<WordpressResponse<T?>> updateRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw const RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      _invokeStatisticsCallback(
        Uri.tryParse(parseUrl(_baseUrl, request.endpoint)).toString(),
        request.endpoint,
      );

      final dioResponse = await _client.request<dynamic>(
        request.endpoint.startsWith('/')
            ? request.endpoint
            : '/${request.endpoint}',
        data: request.body,
        cancelToken: request.cancelToken,
        queryParameters: request.queryParams,
        onSendProgress: request.callback?.onSendProgress,
        onReceiveProgress: request.callback?.onReceiveProgress,
        options: Options(
          method: request.method.name,
          sendTimeout: request.sendTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
      );

      watch.stop();

      _invokeStatisticsCallback(
        Uri.tryParse(parseUrl(_baseUrl, request.endpoint)).toString(),
        request.endpoint,
      );

      if (dioResponse.statusCode == null) {
        throw const NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<T?>.failed(
          null,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return WordpressResponse<T?>.failed(
          response,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        requestDuration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return WordpressResponse<T?>.failed(
        null,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _processRequest(WordpressRequest request) async {
    if (request.shouldAuthorize) {
      await _authorize(
        request: request,
        auth: request.authorization!,
        callback: request.callback,
      );
    }

    if (_defaultAuthorization != null && !_defaultAuthorization!.isDefault) {
      await _authorize(
        request: request,
        auth: _defaultAuthorization!,
        callback: request.callback,
      );
    }
  }

  Future<bool> _authorize({
    required WordpressRequest request,
    required IAuthorization auth,
    Callback? callback,
  }) async {
    if (!auth.isValidAuth) {
      return false;
    }

    if (await request.authorization!.isAuthenticated()) {
      request.headers['Authorization'] = (await auth.generateAuthUrl())!;
      return true;
    }

    await auth.init(_client);

    if (await auth.authorize()) {
      request.headers['Authorization'] = (await auth.generateAuthUrl())!;
      return auth.isAuthenticated();
    }

    return false;
  }

  void _invokeStatisticsCallback(String requestUrl, String endpoint) {
    if (_endPointStatistics[endpoint] == null) {
      _endPointStatistics[endpoint] = 1;
    }

    _endPointStatistics[endpoint] = _endPointStatistics[endpoint]! + 1;

    if (_statisticsCallback == null) {
      return;
    }

    _statisticsCallback!(
      requestUrl,
      endpoint,
      _endPointStatistics[endpoint]!,
    );
  }
}
