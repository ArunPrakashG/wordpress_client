import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:wordpress_client/src/constants.dart';

import 'authorization/authorization_base.dart';
import 'builders/request.dart';
import 'client_configuration.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'responses/response_container.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';
import 'utilities/serializable_instance.dart';

class InternalRequester {
  InternalRequester({
    required String baseUrl,
    required String path,
    BootstrapConfiguration configuration = const BootstrapConfiguration(),
  }) {
    _baseUrl = parseUrl(baseUrl, path);
    configure(configuration);
  }

  InternalRequester.emptyInstance();

  Dio? _client;
  String? _baseUrl;
  IAuthorization? _defaultAuthorization;
  bool Function(dynamic)? _responsePreprocessorDelegate;
  static final Map<String, int> _endPointStatistics = <String, int>{};
  static void Function(String baseUrl, String endpoint, int requestCount)?
      _statisticsDelegate;
  bool _isBusy = false;
  bool _singleRequestAtATimeMode = false;

  bool get isBusy => _isBusy;

  void configure(BootstrapConfiguration configuration) {
    _singleRequestAtATimeMode = configuration.waitWhileBusy;

    if (configuration.responsePreprocessorDelegate != null) {
      _responsePreprocessorDelegate =
          configuration.responsePreprocessorDelegate;
    }

    if (configuration.defaultAuthorization != null &&
        !configuration.defaultAuthorization!.isDefault) {
      _defaultAuthorization = configuration.defaultAuthorization;
    }

    if (configuration.statisticsDelegate != null) {
      _statisticsDelegate = configuration.statisticsDelegate;
    }

    if (configuration.defaultUserAgent != null) {
      _client!.options.headers['User-Agent'] = configuration.defaultUserAgent;
    }

    if (configuration.defaultHeaders != null &&
        configuration.defaultHeaders!.isNotEmpty) {
      for (final header in configuration.defaultHeaders!.entries) {
        _client!.options.headers[header.key] = header.value;
      }
    }

    if (_client == null) {
      _client = Dio(
        BaseOptions(
          connectTimeout: configuration.requestTimeout,
          receiveTimeout: configuration.requestTimeout,
          followRedirects: configuration.shouldFollowRedirects,
          maxRedirects: configuration.maxRedirects,
          baseUrl: _baseUrl!,
        ),
      );
    } else {
      _client!.options.connectTimeout = configuration.requestTimeout;
      _client!.options.receiveTimeout = configuration.requestTimeout;
      _client!.options.followRedirects = configuration.shouldFollowRedirects;
      _client!.options.maxRedirects = configuration.maxRedirects;
      _client!.options.baseUrl = _baseUrl!;
    }

    if (configuration.useCookies) {
      _client!.interceptors.add(CookieManager(CookieJar()));
    }

    if (configuration.cacheResponses &&
        configuration.responseCachePath != null) {
      _client!.interceptors.add(
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
      _client!.interceptors.addAll(configuration.interceptors!);
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

  void removeDefaultAuthorization() {
    _defaultAuthorization = null;
  }

  bool _handleResponse<T>(Request<T> request, T responseContainer) {
    request.callback?.invokeResponseCallback(responseContainer);

    if (_responsePreprocessorDelegate != null &&
        !_responsePreprocessorDelegate!(responseContainer)) {
      return false;
    }

    if (request.validationDelegate != null &&
        !request.validationDelegate!(responseContainer)) {
      return false;
    }

    return true;
  }

  Future<ResponseContainer<T?>> createRequest<T extends ISerializable<T>?>(
    T typeResolver,
    Request<T>? request,
  ) async {
    if (typeResolver == null ||
        request == null ||
        !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);

    await waitWhileBusy();

    var watch = Stopwatch()..start();
    _isBusy = true;
    try {
      final response = await _client!.fetch<dynamic>(options);
      watch.stop();

      if (!isInRange(response.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Either response is null or status code is not in range of 200 ~ 300',
        );
      }

      request.callback?.invokeResponseCallback(response.data);

      final responseDataContainer =
          typeResolver.fromJson(response.data as Map<String, dynamic>);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
        message: response.statusMessage,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> deleteRequest<T extends ISerializable<T>?>(
      T typeResolver, Request<T>? request) async {
    if (request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);

    await waitWhileBusy();

    var watch = Stopwatch()..start();
    _isBusy = true;
    try {
      final response = await _client!.fetch(options);
      watch.stop();

      if (!isInRange(response.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Either response is null or status code is not in range of 200 ~ 300',
        );
      }

      request.callback?.invokeResponseCallback(response.data);

      return ResponseContainer<T?>(
        null,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<List<T>?>> listRequest<T extends ISerializable<T>?>(
      T typeResolver, Request<List<T>>? request) async {
    if (typeResolver == null ||
        request == null ||
        !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    await waitWhileBusy();

    var watch = Stopwatch()..start();
    _isBusy = true;
    try {
      final response = await _client!.fetch(options);
      watch.stop();

      if (!isInRange(response.statusCode!, 200, 299)) {
        return ResponseContainer<List<T>?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Either response is null or status code is not in range of 200 ~ 300',
        );
      }

      request.callback?.invokeResponseCallback(response.data);

      if (!(response.data is Iterable<dynamic>)) {
        return ResponseContainer<List<T>?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message: 'Invalid response object received.',
        );
      }

      final responseDataContainer = (response.data as Iterable<dynamic>)
          .map<T>((e) => typeResolver.fromJson(e))
          .toList();

      if (!_handleResponse<List<T>>(request, responseDataContainer)) {
        return ResponseContainer<List<T>?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
        );
      }

      return ResponseContainer<List<T>>(
        responseDataContainer,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<List<T>?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<List<T>?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> retriveRequest<T extends ISerializable<T>?>(
      T typeResolver, Request<T>? request) async {
    if (typeResolver == null ||
        request == null ||
        !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);

    await waitWhileBusy();

    var watch = Stopwatch()..start();
    _isBusy = true;
    try {
      final response = await _client!.fetch(options);
      watch.stop();

      if (!isInRange(response.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Either response is null or status code is not in range of 200 ~ 300',
        );
      }

      request.callback?.invokeResponseCallback(response.data);

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> updateRequest<T extends ISerializable<T>?>(
    T typeResolver,
    Request<T>? request,
  ) async {
    if (typeResolver == null ||
        request == null ||
        !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);

    await waitWhileBusy();

    var watch = Stopwatch()..start();
    _isBusy = true;
    try {
      final response = await _client!.fetch(options);
      watch.stop();

      if (!isInRange(response.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Either response is null or status code is not in range of 200 ~ 300',
        );
      }

      request.callback?.invokeResponseCallback(response.data);

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message:
              'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    } finally {
      _isBusy = false;
    }
  }

  Map<String, dynamic> _parseResponseHeaders(
    Map<String, List<String>> headers,
  ) {
    return headers.map<String, dynamic>(
      (key, value) => MapEntry<String, String>(
        key,
        value.join(';'),
      ),
    );
  }

  Future<RequestOptions> _parseAsDioRequest(Request request) async {
    if (!request.isRequestExecutable) {
      throw NullReferenceException('Request object is null');
    }

    final requestUri = Uri.tryParse(
      parseUrl(
        _baseUrl,
        request.generatedRequestPath,
      ),
    );

    if (requestUri == null) {
      throw RequestUriParsingFailedException('Request path is invalid.');
    }

    _invokeStatisticsCallback(requestUri.toString(), request.endpoint);

    final options = RequestOptions(
      path: requestUri.toString(),
      method: request.httpMethod.toString().split('.').last,
      cancelToken: request.cancelToken,
      followRedirects: true,
      maxRedirects: 5,
      data: request.formBody,
      onReceiveProgress: request.callback?.invokeReceiveProgressCallback,
      onSendProgress: request.callback?.invokeSendProgressCallback,
    );

    var hasAuthorizedAlready = false;

    if (request.shouldAuthorize && !hasAuthorizedAlready) {
      hasAuthorizedAlready = await _authorizeRequest(
        options,
        _client,
        request.authorization,
        callback: request.callback,
      );
    }

    if (_defaultAuthorization != null &&
        !_defaultAuthorization!.isDefault &&
        !hasAuthorizedAlready) {
      hasAuthorizedAlready = await _authorizeRequest(
        options,
        _client,
        _defaultAuthorization,
        callback: request.callback,
      );
    }

    if (request.headers != null && request.headers!.isNotEmpty) {
      for (final pair in request.headers!) {
        options.headers[pair.key] = pair.value;
      }
    }

    return options;
  }

  static Future<bool> _authorizeRequest(
      RequestOptions? requestOptions, Dio? client, IAuthorization? auth,
      {Callback? callback}) async {
    if (auth == null ||
        auth.isDefault ||
        client == null ||
        requestOptions == null) {
      return false;
    }

    if (await auth.isAuthenticated()) {
      requestOptions.headers['Authorization'] = await auth.generateAuthUrl();
      return true;
    }

    await auth.init(client);

    if (await auth.authorize()) {
      requestOptions.headers['Authorization'] = await auth.generateAuthUrl();
      return auth.isAuthenticated();
    }

    return false;
  }

  void _invokeStatisticsCallback(String requestUrl, String? endpoint) {
    if (_endPointStatistics[endpoint ?? ''] == null) {
      _endPointStatistics[endpoint ?? ''] = 1;
    } else {
      _endPointStatistics[endpoint ?? ''] =
          _endPointStatistics[endpoint ?? '']! - 1;
    }

    if (_statisticsDelegate != null) {
      _statisticsDelegate!(
        requestUrl,
        endpoint ?? '',
        _endPointStatistics[endpoint ?? ''] ?? 0,
      );
    }
  }
}
