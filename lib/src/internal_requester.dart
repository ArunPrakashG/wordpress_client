part of 'wordpress_client_base.dart';

typedef StatisticsCallback = void Function(
  String baseUrl,
  String endpoint,
  int requestCount,
);

class InternalRequester {
  InternalRequester.configure(
    this._baseUrl,
    this._path, [
    this._configuration = const BootstrapConfiguration(),
  ]) {
    configure(_configuration);
  }

  final Dio _client = Dio();

  final String _baseUrl;
  final String _path;
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
  String get requestBaseUrl => parseUrl(_baseUrl, _path);

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
    _client.options.baseUrl = _baseUrl;

    if (configuration.useCookies &&
        !_client.interceptors.any((i) => i is CookieManager)) {
      _client.interceptors.add(CookieManager(CookieJar()));
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

  bool _validateResponse<T>(WordpressRequest request, T? response) {
    if (!request.shouldValidateResponse) {
      return true;
    }

    return request.responseValidationCallback!(response);
  }

  String _generatePath(WordpressRequest request) {
    return parseUrl(
      request.path ?? _path,
      request.endpoint,
    );
  }

  Future<Response<dynamic>> _requestAsync(
    WordpressRequest request,
    Stopwatch watch,
  ) async {
    await _processRequest(request);

    _invokeStatisticsCallback(
      Uri.tryParse(parseUrl(requestBaseUrl, request.endpoint)).toString(),
      request.endpoint,
    );

    watch.reset();

    Response<dynamic> response;

    if (_synchronized) {
      response = await _syncLock.synchronized<Response<dynamic>>(
        () async {
          watch.start();

          return _client.request<dynamic>(
            _generatePath(request),
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
            ),
          );
        },
      );
    } else {
      watch.start();

      response = await _client.request<dynamic>(
        _generatePath(request),
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
        ),
      );
    }

    watch.stop();

    if (response.statusCode == null) {
      throw NullReferenceException(
          'Response status code is null. This means the request never reached the server. Please check your internet connection.');
    }

    return response;
  }

  Future<WordpressResponse<T?>> createRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final watch = Stopwatch();

    try {
      final dioResponse = await _requestAsync(request, watch);

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<T?>.failed(
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          headers: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return WordpressResponse<T?>.failed(
          responseData: response,
          duration: watch.elapsed,
          headers: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<T>.success(
        responseData: response,
        responseCode: dioResponse.statusCode!,
        headers: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return WordpressResponse<T?>.failed(
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    }
  }

  Future<WordpressResponse<bool>> deleteRequest(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final watch = Stopwatch();

    try {
      final dioResponse = await _requestAsync(request, watch);

      if (!isInRange(dioResponse.statusCode!, 200, 399)) {
        return WordpressResponse<bool>.failed(
          false,
          requestDuration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      if (!_validateResponse<bool>(request, true)) {
        return WordpressResponse<bool>.failed(
          false,
          requestDuration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return WordpressResponse<bool>(
        true,
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

      return WordpressResponse<bool>.failed(
        false,
        requestDuration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    }
  }

  Future<WordpressResponse<List<T>?>> listRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final watch = Stopwatch();

    try {
      final dioResponse = await _requestAsync(request, watch);

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
          .map<T>((dynamic e) => deserialize<T>(e))
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
    }
  }

  Future<WordpressResponse<T?>> retriveRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final watch = Stopwatch();

    try {
      final dioResponse = await _requestAsync(request, watch);

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
    }
  }

  Future<WordpressResponse<T?>> updateRequest<T>(
    WordpressRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final watch = Stopwatch();

    try {
      final dioResponse = await _requestAsync(request, watch);

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
    WordpressCallback? callback,
  }) async {
    if (await auth.isAuthenticated()) {
      request.headers['Authorization'] = (await auth.generateAuthUrl())!;
      return true;
    }

    final dioAuthClient = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: _client.options.headers,
        connectTimeout: _client.options.connectTimeout,
        receiveTimeout: _client.options.receiveTimeout,
        sendTimeout: _client.options.sendTimeout,
        followRedirects: _client.options.followRedirects,
        maxRedirects: _client.options.maxRedirects,
      ),
    );

    if (_isDebugMode) {
      dioAuthClient.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    await auth._init(
      dioClient: dioAuthClient,
      baseUrl: _baseUrl,
      path: _path,
    );

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
