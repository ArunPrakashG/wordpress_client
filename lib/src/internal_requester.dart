part of 'wordpress_client_base.dart';

typedef StatisticsCallback = void Function(
  String baseUrl,
  String endpoint,
  int requestCount,
);

class InternalRequester {
  InternalRequester.configure(
    this._baseUrl,
    this._path, {
    BootstrapConfiguration configuration = const BootstrapConfiguration(),
  }) {
    configure(configuration);
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

    if (configuration.useCookies) {
      _client.interceptors.add(CookieManager(CookieJar()));
    }

    if (configuration.enableDebugMode) {
      _client.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    if (configuration.interceptors != null &&
        configuration.interceptors!.isNotEmpty) {
      _client.interceptors.addAll(configuration.interceptors!);
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
        timeout: const Duration(
          minutes: 1,
        ),
      );
    } else {
      watch.start();

      response = await _client.request<dynamic>(
        parseUrl(
          _path,
          request.endpoint.startsWith('/')
              ? request.endpoint
              : '/${request.endpoint}',
        ),
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

  Future<WordpressResponse<T?>> deleteRequest<T>(
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
    if (!auth.isValidAuth) {
      return false;
    }

    if (await request.authorization!.isAuthenticated()) {
      request.headers['Authorization'] = (await auth.generateAuthUrl())!;
      return true;
    }

    await auth._init(
      dioClient: _client,
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

/// Base class for all authorization types.
///
/// To create a custom authorization system, simply extend from this abstract class, then implement its functions
/// then pass base class to Authorization builder function!
///
/// There is no storage system to store the nounce inside the client, therefore the base class has the responsibility to handle this mechanism.
abstract class IAuthorization {
  /// Default constructor, used to pass username and password.
  IAuthorization(this.userName, this.password, {this.callback});

  late final String baseUrl;
  late final String path;
  String get requestBaseUrl => parseUrl(baseUrl, path);
  late final Dio client;

  /// The username
  String? userName;

  /// The password
  String? password;

  // A Callback, if assigned, will help with logging of data of requests send and received on this instance.
  WordpressCallback? callback;

  /// Gets if this authorization instance has valid authentication nounce. (token/encryptedToken)
  bool get isValidAuth;

  /// Gets if this is an invalid or default authorization instance without username or password fields.
  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);

  /// Helps to initialize authorization instance with internal requesting client passed as a parameter.
  ///
  /// This function is called only if there is no valid nounce available ie., when isAuthenticated() returns false.
  /// Internal client will be passed as a parameter to this function which you can store inside the instance for internal authorization requests.
  ///
  /// authorize() / validate() functions will not be called before calling init() function.
  ///
  /// If you require Http request calls inside isAuthenticated() / generateAuthUrl() calls, then you will need to implement your own requesting mechanism  ///
  Future<bool> _init({
    required Dio dioClient,
    required String baseUrl,
    required String path,
  }) async {
    baseUrl = baseUrl;
    client = dioClient;
    path = path;
    return true;
  }

  /// Called to validate token. (such as in JWT auth)
  ///
  /// As of right now, this function is not called outside of this instance. This can change in the future if there is a requirement to validate the nounce from the core client itself.
  /// Therefore, be sure to implement this with valid logic for the validation process.
  ///
  /// Example 1: JWT authentication token can be validated through an endpoint, you can implement that validation logic inside this.
  ///
  /// Example 2: Basic Auth does not require any validation, therefore you can simply return true or if still require some custom logic, you can implement that as well!
  Future<bool> validate();

  /// Called to check if this instance has a valid authentication nounce and generateAuthUrl() won't return false.
  ///
  /// This function will be called before init() function, therefore if you are using client instance passed through init() then there will be NullReferenceException.
  ///
  /// If you require HTTP requests in this method, then you need to implement custom logic.
  Future<bool> isAuthenticated();

  /// Called to authorize a request if the request requires authentication.
  ///
  /// Returning true means the request should be authorized, false means authorization failed.
  Future<bool> authorize();

  /// After authorize() is called, to get the authorization header string, (ie, '{scheme} {token}') the client calls this method to generate the raw string.
  ///
  /// The returning string formate must always be like
  ///
  /// {scheme} {token}
  ///
  /// Example 1: In case of JWT
  /// Bearer {jwt_token}
  ///
  /// Example 2: In case of Basic Auth
  /// Basic {base64 encoded username and password}
  Future<String?> generateAuthUrl();
}
