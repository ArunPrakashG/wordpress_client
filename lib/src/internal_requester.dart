import 'package:dio/dio.dart';
import 'package:wordpress_client/src/client_configuration.dart';

import 'enums.dart';
import 'exceptions/authorization_failed_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'requests/request.dart';
import 'responses/response_container.dart';
import 'utilities/cookie_container.dart';
import 'utilities/helpers.dart';
import 'utilities/pair.dart';
import 'utilities/serializable_instance.dart';
import 'wordpress_authorization.dart';

const int defaultRequestTimeout = 60 * 1000;

class InternalRequester {
  Dio _client;
  String _baseUrl;
  WordpressAuthorization _defaultAuthorization;
  bool Function(dynamic) _responsePreprocessorDelegate;

  InternalRequester(String baseUrl, String path, BootstrapConfiguration configuration) {
    if (baseUrl == null) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (path == null) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    if (configuration == null) {
      configuration = new BootstrapConfiguration(
        cookieContainer: CookieContainer(),
        requestTimeout: defaultRequestTimeout,
        shouldFollowRedirects: true,
        maxRedirects: 5,
      );
    }

    _baseUrl = parseUrl(baseUrl, path);

    // TODO: configuration.cookieContainer

    _responsePreprocessorDelegate = configuration.responsePreprocessorDelegate;
    _defaultAuthorization = configuration.defaultAuthorization;
    _handleDefaultAuthorization(configuration.defaultAuthorization);

    if (configuration.defaultUserAgent != null) {
      _client.options.headers['User-Agent'] = configuration.defaultUserAgent;
    }

    if (configuration.defaultHeaders != null && configuration.defaultHeaders.isNotEmpty) {
      for (final header in configuration.defaultHeaders) {
        _client.options.headers[header.key] = header.value;
      }
    }

    _client = Dio(
      BaseOptions(
        connectTimeout: configuration.requestTimeout,
        receiveTimeout: configuration.requestTimeout,
        followRedirects: configuration.shouldFollowRedirects,
        maxRedirects: configuration.maxRedirects,
        baseUrl: _baseUrl,
      ),
    );
  }

  void _handleDefaultAuthorization(WordpressAuthorization auth) async {
    if (auth == null || auth.isDefault) {
      return;
    }

    if (_defaultAuthorization != null && !_defaultAuthorization.isDefault) {
      return;
    }

    _defaultAuthorization = auth;
    var encryptedAccessToken = null;
    if (!_defaultAuthorization.isValidAuth &&
        _defaultAuthorization.authType == AuthorizationType.JWT &&
        !await _defaultAuthorization.handleJwtAuthentication(_client, (token) {
          encryptedAccessToken = token;
        })) {
      return;
    }

    if (!isNullOrEmpty(encryptedAccessToken)) {
      _client.options.headers['Authorization'] = '${_defaultAuthorization.scheme} $encryptedAccessToken';
    }
  }

  // Always POST
  Future<ResponseContainer<T>> createRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(await _parseAsDioRequest(request));
      watch.stop();

      if (response == null || response.statusCode != 200) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: response.statusMessage,
          status: false,
          responseCode: response.statusCode,
        );
      }

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in responsePreprocessorDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      if (request.callback?.responseCallback != null) {
        request.callback.responseCallback(responseDataContainer);
      }

      if (request.validationDelegate != null && !request.validationDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        status: true,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on Exception catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        errorMessage: 'Exception occured.',
        status: false,
        exception: e,
        responseCode: 400,
      );
    }
  }

  // always DELETE
  // No validator
  Future<ResponseContainer<T>> deleteRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(await _parseAsDioRequest(request));
      watch.stop();

      if (response == null || response.statusCode != 200) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: response.statusMessage,
          status: false,
          responseCode: response.statusCode,
        );
      }

      if (request.callback?.responseCallback != null) {
        request.callback.responseCallback(response.data);
      }

      return ResponseContainer<T>(
        null,
        responseCode: response.statusCode,
        status: response.statusCode == 200,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on Exception catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        errorMessage: 'Exception occured.',
        status: false,
        exception: e,
        responseCode: 400,
      );
    }
  }

  Future<ResponseContainer<List<T>>> listRequest<T extends ISerializable<T>>(T typeResolver, Request<List<T>> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(await _parseAsDioRequest(request));
      watch.stop();

      if (response == null || response.statusCode != 200) {
        return ResponseContainer<List<T>>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: response.statusMessage,
          status: false,
          responseCode: response.statusCode,
        );
      }

      final responseDataContainer = (response.data as Iterable<dynamic>).map<T>((e) => typeResolver.fromJson(e)).toList();

      if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(responseDataContainer)) {
        return ResponseContainer<List<T>>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in responsePreprocessorDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      if (request.callback?.responseCallback != null) {
        request.callback.responseCallback(responseDataContainer);
      }

      if (request.validationDelegate != null && !request.validationDelegate(responseDataContainer)) {
        return ResponseContainer<List<T>>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<List<T>>(
        responseDataContainer,
        responseCode: response.statusCode,
        status: true,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on Exception catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<List<T>>.failed(
        null,
        duration: watch.elapsed,
        errorMessage: 'Exception occured.',
        status: false,
        exception: e,
        responseCode: 400,
      );
    }
  }

  Future<ResponseContainer<T>> retriveRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(await _parseAsDioRequest(request));
      watch.stop();

      if (response == null || response.statusCode != 200) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: response.statusMessage,
          status: false,
          responseCode: response.statusCode,
        );
      }

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in responsePreprocessorDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      if (request.callback?.responseCallback != null) {
        request.callback.responseCallback(responseDataContainer);
      }

      if (request.validationDelegate != null && !request.validationDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        status: true,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on Exception catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        errorMessage: 'Exception occured.',
        status: false,
        exception: e,
        responseCode: 400,
      );
    }
  }

  Future<ResponseContainer<T>> updateRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(await _parseAsDioRequest(request));
      watch.stop();

      if (response == null || response.statusCode != 200) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: response.statusMessage,
          status: false,
          responseCode: response.statusCode,
        );
      }

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in responsePreprocessorDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      if (request.callback?.responseCallback != null) {
        request.callback.responseCallback(response.data);
      }

      if (request.validationDelegate != null && !request.validationDelegate(responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<T>(
        responseDataContainer,
        responseCode: response.statusCode,
        status: true,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on Exception catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        errorMessage: 'Exception occured.',
        status: false,
        exception: e,
        responseCode: 400,
      );
    }
  }

  List<Pair<String, String>> _parseResponseHeaders(Map<String, List<String>> headers) {
    if (headers == null) {
      return [];
    }

    var headerPairs = <Pair<String, String>>[];
    for (final header in headers.entries) {
      headerPairs.add(Pair(header.key, header.value.join(';')));
    }

    return headerPairs;
  }

  Future<RequestOptions> _parseAsDioRequest(Request request) async {
    if (request == null || !request.isRequestExecutable) {
      throw NullReferenceException('Request object is null');
    }

    Uri requestUri = Uri.tryParse(parseUrl(_baseUrl, request.generatedRequestPath));

    if (requestUri == null) {
      throw RequestUriParsingFailedException('Request path is invalid.');
    }

    RequestOptions options = RequestOptions(
      path: requestUri.toString(),
      method: request.httpMethod.toString().split('.').last,
      cancelToken: request.cancelToken,
      receiveTimeout: defaultRequestTimeout,
      sendTimeout: defaultRequestTimeout,
      connectTimeout: defaultRequestTimeout,
      followRedirects: true,
      maxRedirects: 5,
    );

    if (request.shouldAuthorize) {
      options = await WordpressAuthorization.authorizeRequest(options, _client, request.authorization);

      if (options == null) {
        throw AuthorizationFailedException();
      }
    }

    print('Request URL: ${options.path}');

    if (request.headers != null && request.headers.isNotEmpty) {
      for (final pair in request.headers) {
        options.headers[pair.key] = pair.value;
      }
    }

    if (request.httpMethod != HttpMethod.GET && request.formBody != null) {
      switch (request.formBody['REQUEST_TYPE']) {
        case 'media_request':
          options.headers.addEntries(request.formBody.entries.where((element) => element.key != 'file'));
          options.data = request.formBody['file'];
          break;
        case 'post_request':
          options.data = request.formBody;
          break;
      }
    }

    return options;
  }
}
