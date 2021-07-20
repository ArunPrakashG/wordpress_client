import 'dart:convert';

import 'package:dio/dio.dart';

import 'authorization.dart';
import 'builders/request.dart';
import 'client_configuration.dart';
import 'enums.dart';
import 'exceptions/authorization_failed_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'responses/jwt_token_response.dart';
import 'responses/jwt_validate_response.dart';
import 'responses/response_container.dart';
import 'utilities/callback.dart';
import 'utilities/cookie_container.dart';
import 'utilities/helpers.dart';
import 'utilities/pair.dart';
import 'utilities/serializable_instance.dart';
import 'wordpress_client_base.dart';

part 'authorization_handler.dart';

const int defaultRequestTimeout = 60 * 1000;

class InternalRequester {
  Dio _client;
  String _baseUrl;
  AuthorizationHandler _defaultAuthorization;
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

    if (configuration.defaultAuthorization != null && !configuration.defaultAuthorization.isDefault) {
      _defaultAuthorization = AuthorizationHandler(
        configuration.defaultAuthorization.userName,
        configuration.defaultAuthorization.password,
        configuration.defaultAuthorization.authType,
        configuration.defaultAuthorization.jwtToken,
      );

      _handleDefaultAuthorization(_defaultAuthorization);
    }

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

  void removeDefaultAuthorization() {
    if (_defaultAuthorization != null) {
      _defaultAuthorization.logout();
    }

    _defaultAuthorization = null;
  }

  void _handleDefaultAuthorization(AuthorizationHandler auth) async {
    if (auth == null || auth.isDefault) {
      return;
    }

    if (_defaultAuthorization != null && !_defaultAuthorization.isDefault) {
      return;
    }

    if (auth.isValidAuth) {
      _defaultAuthorization = auth;
      _client.options.headers['Authorization'] = '${_defaultAuthorization._scheme} ${_defaultAuthorization._encryptedAccessToken}';
      return;
    }

    switch (auth._authType) {
      case AuthorizationType.JWT:
        auth.handleJwtAuthentication(_client);

        if (!auth.isValidAuth) {
          throw AuthorizationFailedException();
        }

        break;
      case AuthorizationType.BASIC:
        // already handled in constructor
        break;
    }

    _defaultAuthorization = auth;
    _client.options.headers['Authorization'] = '${_defaultAuthorization._scheme} ${_defaultAuthorization._encryptedAccessToken}';
  }

  bool _handleResponse<T>(Request<T> request, T responseContainer) {
    request.callback?.invokeResponseCallback(responseContainer);

    if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(responseContainer)) {
      return false;
    }

    if (request.validationDelegate != null && !request.validationDelegate(responseContainer)) {
      return false;
    }

    return true;
  }

  Future<ResponseContainer<T>> createRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      return ResponseContainer<T>.failed(
        null,
        duration: null,
        responseCode: -1,
        message: 'Authorization might have failed internally.',
      );
    }

    var watch = Stopwatch()..start();
    try {    
      final response = await _client.fetch(options);
      watch.stop();

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message: 'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
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

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    }
  }

  Future<ResponseContainer<T>> deleteRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      return ResponseContainer<T>.failed(
        null,
        duration: null,
        responseCode: -1,
        message: 'Authorization might have failed internally.',
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

      return ResponseContainer<T>(
        null,
        responseCode: response.statusCode,
        responseHeaders: _parseResponseHeaders(response.headers.map),
        duration: watch.elapsed,
      );
    } on DioError catch (e) {
      request.callback?.invokeRequestErrorCallback(e);

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    }
  }

  Future<ResponseContainer<List<T>>> listRequest<T extends ISerializable<T>>(T typeResolver, Request<List<T>> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      return ResponseContainer<List<T>>.failed(
        null,
        duration: null,
        responseCode: -1,
        message: 'Authorization might have failed internally.',
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

      final responseDataContainer = (response.data as Iterable<dynamic>).map<T>((e) => typeResolver.fromJson(e)).toList();

      if (!_handleResponse<List<T>>(request, responseDataContainer)) {
        return ResponseContainer<List<T>>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message: 'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
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

      return ResponseContainer<List<T>>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<List<T>>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    }
  }

  Future<ResponseContainer<T>> retriveRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      return ResponseContainer<T>.failed(
        null,
        duration: null,
        responseCode: -1,
        message: 'Authorization might have failed internally.',
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message: 'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
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

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
      );
    }
  }

  Future<ResponseContainer<T>> updateRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      return ResponseContainer<T>.failed(
        null,
        duration: null,
        responseCode: -1,
        message: 'Authorization might have failed internally.',
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

      final responseDataContainer = typeResolver.fromJson(response.data);

      if (!_handleResponse<T>(request, responseDataContainer)) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          responseCode: response.statusCode,
          message: 'Request aborted by user either in responsePreprocessorDelegate() or validationDelegate()',
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

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${e.toString()})',
        responseCode: -1,
      );
    } on Exception catch (ex) {
      request.callback?.invokeUnhandledExceptionCallback(ex);

      return ResponseContainer<T>.failed(
        null,
        duration: watch.elapsed,
        message: 'Exception occured. (${ex.toString()})',
        responseCode: -1,
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

    Uri requestUri = Uri.tryParse(parseUrl(
      _baseUrl,
      request.httpMethod == HttpMethod.POST ? request.endpoint : request.generatedRequestPath,
    ));

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
      data: request.formBody,
      onReceiveProgress: request.callback.onReceiveProgress,
      onSendProgress: request.callback.onSendProgress,
    );

    bool hasAuthorizedAlready = false;

    if (request.shouldAuthorize) {
      options = await AuthorizationHandler.authorizeRequest(options, _client, request.authorization, callback: request.callback);

      if (options == null) {
        return null;
      }

      hasAuthorizedAlready = true;
    }

    if (_defaultAuthorization != null && _defaultAuthorization.isValidAuth && !hasAuthorizedAlready) {
      options = await AuthorizationHandler.authorizeRequest(
          options,
          _client,
          Authorization(
            userName: _defaultAuthorization._userName,
            password: _defaultAuthorization._password,
            authType: _defaultAuthorization._authType,
            jwtToken: _defaultAuthorization._jwtToken,
          ),
          callback: request.callback);

      if (options == null) {
        return null;
      }

      hasAuthorizedAlready = true;
    }

    print('Request URL: ${options.path}');

    if (request.headers != null && request.headers.isNotEmpty) {
      for (final pair in request.headers) {
        options.headers[pair.key] = pair.value;
      }
    }

    /*
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
    */
    return options;
  }
}
