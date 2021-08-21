import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'authorization/authorization_base.dart';
import 'builders/request.dart';
import 'client_configuration.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'responses/response_container.dart';
import 'utilities/callback.dart';
import 'utilities/helpers.dart';
import 'utilities/serializable_instance.dart';

const int defaultRequestTimeout = 60 * 1000;

class InternalRequester {
  Dio? _client;
  String? _baseUrl;
  IAuthorization? _defaultAuthorization;
  bool Function(dynamic)? _responsePreprocessorDelegate;
  static final Map<String?, int> endPointStatistics = Map<String?, int>();
  static void Function(String, String?, int?)? _statisticsDelegate;
  bool? _isBusy;
  bool _singleRequestAtATimeMode = false;

  InternalRequester(
      String? baseUrl, String? path, BootstrapConfiguration? configuration) {
    if (baseUrl == null) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (path == null) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    if (configuration == null) {
      configuration = new BootstrapConfiguration(
        useCookies: false,
        requestTimeout: defaultRequestTimeout,
        shouldFollowRedirects: true,
        maxRedirects: 5,
      );
    }

    _baseUrl = parseUrl(baseUrl, path);
    configure(configuration);
  }

  void configure(BootstrapConfiguration configuration) {
    _singleRequestAtATimeMode = configuration.waitWhileBusy ?? false;

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
      for (final header in configuration.defaultHeaders!) {
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
      _client!.options.connectTimeout = configuration.requestTimeout!;
      _client!.options.receiveTimeout = configuration.requestTimeout!;
      _client!.options.followRedirects = configuration.shouldFollowRedirects!;
      _client!.options.maxRedirects = configuration.maxRedirects!;
      _client!.options.baseUrl = _baseUrl!;
    }

    if (configuration.useCookies ?? false) {
      _client!.interceptors.add(CookieManager(CookieJar()));
    }
  }

  Future<void> waitWhileBusy() async {
    if (!_singleRequestAtATimeMode) {
      return;
    }

    while (_isBusy!) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  bool? getBusyStatus() => _isBusy;

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

  Map<String, dynamic> _parseResponseHeaders(
          Map<String, List<String>> headers) =>
      headers
          .map<String, dynamic>((key, value) => MapEntry(key, value.join(';')));

  Future<RequestOptions> _parseAsDioRequest(Request request) async {
    if (!request.isRequestExecutable) {
      throw NullReferenceException('Request object is null');
    }

    Uri? requestUri = Uri.tryParse(parseUrl(
      _baseUrl,
      request.generatedRequestPath,
    ));

    if (requestUri == null) {
      throw RequestUriParsingFailedException('Request path is invalid.');
    }

    _invokeStatisticsCallback(requestUri.toString(), request.endpoint);

    RequestOptions options = RequestOptions(
      path: requestUri.toString(),
      method: request.httpMethod.toString().split('.').last,
      cancelToken: request.cancelToken,
      receiveTimeout: defaultRequestTimeout,
      sendTimeout: defaultRequestTimeout,
      connectTimeout: defaultRequestTimeout,
      followRedirects: true,
      maxRedirects: 5,
      data: request.formBody,
      onReceiveProgress: (current, max) =>
          request.callback?.invokeReceiveProgressCallback(max, current),
      onSendProgress: (current, max) =>
          request.callback?.invokeSendProgressCallback(max, current),
    );

    bool hasAuthorizedAlready = false;

    if (request.shouldAuthorize && !hasAuthorizedAlready) {
      hasAuthorizedAlready = await _authorizeRequest(
          options, _client, request.authorization,
          callback: request.callback);
    }

    if (_defaultAuthorization != null &&
        !_defaultAuthorization!.isDefault &&
        !hasAuthorizedAlready) {
      hasAuthorizedAlready = await _authorizeRequest(
          options, _client, _defaultAuthorization,
          callback: request.callback);
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
    if (endPointStatistics[endpoint] == null) {
      endPointStatistics[endpoint] = 1;
    } else {
      endPointStatistics[endpoint] = endPointStatistics[endpoint]! - 1;
    }

    if (_statisticsDelegate != null) {
      _statisticsDelegate!(requestUrl, endpoint, endPointStatistics[endpoint]);
    }
  }
}
