import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'authorization/authorization_base.dart';
import 'client_configuration.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'requests/generic_request.dart';
import 'responses/response_container.dart';
import 'type_map.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';

typedef StatisticsCallback = void Function(
  String baseUrl,
  String endpoint,
  int requestCount,
);

class InternalRequester {
  InternalRequester({
    required String baseUrl,
    required String path,
    required this.typeMap,
    BootstrapConfiguration configuration = const BootstrapConfiguration(),
  }) {
    _baseUrl = parseUrl(baseUrl, path);
    configure(configuration);
  }

  final Dio _client = Dio();
  late final String _baseUrl;
  final TypeMap typeMap;
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

  void removeDefaultAuthorization() {
    _defaultAuthorization = null;
  }

  bool _validateResponse<T>(GenericRequest request, T? response) {
    if (!request.shouldValidateResponse) {
      return true;
    }

    return request.responseValidationCallback!(response);
  }

  Future<ResponseContainer<T?>> createRequest<T>(GenericRequest request) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      final dioResponse = await _client.request<dynamic>(
        request.endpoint,
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
        throw NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return ResponseContainer<T?>.failed(
          response,
          duration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return ResponseContainer<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> deleteRequest<T>(GenericRequest request) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      final dioResponse = await _client.request<dynamic>(
        request.endpoint,
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
        throw NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      if (!_validateResponse<T>(request, null)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return ResponseContainer<T?>(
        null,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<List<T>?>> listRequest<T>(
    GenericRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      final dioResponse = await _client.request<dynamic>(
        request.endpoint,
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
        throw NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 299)) {
        return ResponseContainer<List<T>?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      if (dioResponse.data is! Iterable<dynamic>) {
        return ResponseContainer<List<T>?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          message: 'Response is not a list.',
        );
      }

      final response = (dioResponse.data as Iterable<dynamic>)
          .map<T>(deserialize<T>)
          .toList();

      if (!_validateResponse<List<T>>(request, response)) {
        return ResponseContainer<List<T>?>.failed(
          response,
          duration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return ResponseContainer<List<T>>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return ResponseContainer<List<T>?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> retriveRequest<T>(
    GenericRequest request,
  ) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      final dioResponse = await _client.request<dynamic>(
        request.endpoint,
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
        throw NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return ResponseContainer<T?>.failed(
          response,
          duration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return ResponseContainer<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<ResponseContainer<T?>> updateRequest<T>(GenericRequest request) async {
    if (!request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    await waitWhileBusy();
    final watch = Stopwatch()..start();
    _isBusy = true;

    try {
      await _processRequest(request);

      final dioResponse = await _client.request<dynamic>(
        request.endpoint,
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
        throw NullReferenceException(
            'Response status code is null. This means the request never reached the server. Please check your internet connection.');
      }

      if (!isInRange(dioResponse.statusCode!, 200, 299)) {
        return ResponseContainer<T?>.failed(
          null,
          duration: watch.elapsed,
          responseCode: dioResponse.statusCode!,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          message: dioResponse.statusMessage ??
              'Request failed with status code ${dioResponse.statusCode}',
        );
      }

      request.callback?.invokeResponseCallback(dioResponse.data);

      final response = deserialize<T>(dioResponse.data);

      if (!_validateResponse<T>(request, response)) {
        return ResponseContainer<T?>.failed(
          response,
          duration: watch.elapsed,
          responseHeaders: dioResponse.headers.getHeaderMap(),
          responseCode: dioResponse.statusCode!,
          message: 'Manual response validation failed.',
        );
      }

      return ResponseContainer<T>(
        response,
        responseCode: dioResponse.statusCode!,
        responseHeaders: dioResponse.headers.getHeaderMap(),
        duration: watch.elapsed,
        message: dioResponse.statusMessage,
      );
    } catch (e) {
      if (e is DioError) {
        request.callback?.invokeDioErrorCallback(e);
      } else {
        request.callback?.invokeUnhandledExceptionCallback(e as Exception);
      }

      return ResponseContainer<T?>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _processRequest(GenericRequest request) async {
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
    required GenericRequest request,
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
