import 'dart:convert';

import 'package:dio/dio.dart';

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

    if (auth.isValidAuth) {
      _defaultAuthorization = auth;
      _client.options.headers['Authorization'] = '${_defaultAuthorization._scheme} ${_defaultAuthorization._encryptedAccessToken}';
      return;
    }

    switch (auth._authType) {
      case AuthorizationType.JWT:
        auth._handleJwtAuthentication(_client);

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

  Future<ResponseContainer<T>> createRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      if (request.callback != null && request.callback.requestCallback != null) {
        request.callback.requestCallback(RequestStatus(false, 'Authorization failed.'));
      }

      return ResponseContainer<T>.failed(
        null,
        duration: null,
        errorMessage: 'Authorization failed.',
        status: false,
        responseCode: -1,
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

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
    } on DioError catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(null,
          duration: watch.elapsed, errorMessage: 'Exception occured. (${e.toString()})', status: false, responseCode: -1, dioError: e);
    }
  }

  Future<ResponseContainer<T>> deleteRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      if (request.callback != null && request.callback.requestCallback != null) {
        request.callback.requestCallback(RequestStatus(false, 'Authorization failed.'));
      }

      return ResponseContainer<T>.failed(
        null,
        duration: null,
        errorMessage: 'Authorization failed.',
        status: false,
        responseCode: -1,
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

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
    } on DioError catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(null,
          duration: watch.elapsed, errorMessage: 'Exception occured. (${e.toString()})', status: false, responseCode: -1, dioError: e);
    }
  }

  Future<ResponseContainer<List<T>>> listRequest<T extends ISerializable<T>>(T typeResolver, Request<List<T>> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      if (request.callback != null && request.callback.requestCallback != null) {
        request.callback.requestCallback(RequestStatus(false, 'Authorization failed.'));
      }

      return ResponseContainer<List<T>>.failed(
        null,
        duration: null,
        errorMessage: 'Authorization failed.',
        status: false,
        responseCode: -1,
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

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
    } on DioError catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<List<T>>.failed(null,
          duration: watch.elapsed, errorMessage: 'Exception occured. (${e.toString()})', status: false, responseCode: -1, dioError: e);
    }
  }

  Future<ResponseContainer<T>> retriveRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      if (request.callback != null && request.callback.requestCallback != null) {
        request.callback.requestCallback(RequestStatus(false, 'Authorization failed.'));
      }

      return ResponseContainer<T>.failed(
        null,
        duration: null,
        errorMessage: 'Authorization failed.',
        status: false,
        responseCode: -1,
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

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
    } on DioError catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(null,
          duration: watch.elapsed, errorMessage: 'Exception occured. (${e.toString()})', status: false, responseCode: -1, dioError: e);
    }
  }

  Future<ResponseContainer<T>> updateRequest<T extends ISerializable<T>>(T typeResolver, Request<T> request) async {
    if (typeResolver == null || request == null || !request.isRequestExecutable) {
      throw RequestUriParsingFailedException('Request is invalid.');
    }

    final options = await _parseAsDioRequest(request);
    if (options == null) {
      if (request.callback != null && request.callback.requestCallback != null) {
        request.callback.requestCallback(RequestStatus(false, 'Authorization failed.'));
      }

      return ResponseContainer<T>.failed(
        null,
        duration: null,
        errorMessage: 'Authorization failed.',
        status: false,
        responseCode: -1,
      );
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(options);
      watch.stop();

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
    } on DioError catch (e) {
      if (request.callback?.unhandledExceptionCallback != null) {
        request.callback.unhandledExceptionCallback(e);
      }

      return ResponseContainer<T>.failed(null,
          duration: watch.elapsed, errorMessage: 'Exception occured. (${e.toString()})', status: false, responseCode: -1, dioError: e);
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
    );

    if (request.shouldAuthorize) {
      options = await WordpressAuthorization._authorizeRequest(options, _client, request.authorization, callback: request.callback);

      if (options == null) {
        return null;
      }
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

class WordpressAuthorization {
  WordpressAuthorization(this._userName, this._password, this._authType, [this._jwtToken = null]) {
    _scheme = '';
    _encryptedAccessToken = '';
    _hasValidatedOnce = false;

    if (isDefault) {
      return;
    }

    switch (_authType) {
      case AuthorizationType.JWT:
        _scheme = 'Bearer';
        _encryptedAccessToken = _jwtToken;
        break;
      case AuthorizationType.BASIC:
        _scheme = 'Basic';
        _encryptedAccessToken = base64Encode('$_userName:$_password');
        break;
    }
  }

  String _userName;
  String _password;
  String _jwtToken;
  AuthorizationType _authType;
  String _scheme;
  String _encryptedAccessToken;
  bool _hasValidatedOnce;

  bool get isValidAuth => !isNullOrEmpty(_encryptedAccessToken);

  bool get isDefault => isNullOrEmpty(_userName) || isNullOrEmpty(_password);

  bool logout() {
    _encryptedAccessToken = null;
    return true;
  }

  void _handleJwtAuthentication(Dio client, {Callback callback}) async {
    if (_authType != AuthorizationType.JWT || client == null) {
      return;
    }

    if (_hasValidatedOnce && !isNullOrEmpty(_encryptedAccessToken)) {
      return;
    }

    if (!isNullOrEmpty(_encryptedAccessToken)) {
      bool valid = false;
      _validateExistingJwtToken(client, (isValid) => valid = isValid, callback: callback);

      if (valid) {
        return;
      }
    }

    try {
      final response = await client.post(
        parseUrl(WordpressClient.baseUrl, 'jwt-auth/v1/token'),
        data: {
          'username': _userName,
          'password': _password,
        },
        options: Options(
          method: 'POST',
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response == null || response.statusCode != 200) {
        return;
      }

      _encryptedAccessToken = JwtToken.fromMap(response.data).token;
    } on DioError catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback(e);
      }
    }
  }

  void _validateExistingJwtToken(Dio client, void Function(bool) isValid, {Callback callback}) async {
    return await _validateJwtToken(client, _encryptedAccessToken, isValid, callback: callback);
  }

  void _validateJwtToken(Dio client, String jwtToken, void Function(bool) isValid, {Callback callback}) async {
    if (_authType != AuthorizationType.JWT || client == null || isNullOrEmpty(jwtToken)) {
      return isValid(false);
    }

    try {
      final response = await client.post(
        parseUrl(WordpressClient.baseUrl, 'jwt-auth/v1/token/validate'),
        options: Options(
          method: 'POST',
          headers: {'Authorization': '$_scheme $jwtToken'},
        ),
      );

      if (response == null || response.statusCode != 200) {
        return isValid(false);
      }

      final validationResult = JwtValidate.fromMap(response.data);
      if (validationResult == null || isNullOrEmpty(validationResult.code)) {
        return isValid(false);
      }

      return isValid(_hasValidatedOnce = validationResult.code == 'jwt_auth_valid_token');
    } on DioError catch (e) {
      if (callback != null && callback.unhandledExceptionCallback != null) {
        callback.unhandledExceptionCallback(e);
      }

      return isValid(false);
    }
  }

  static Future<RequestOptions> _authorizeRequest(RequestOptions requestOptions, Dio client, WordpressAuthorization auth, {Callback callback}) async {
    if (auth == null || auth.isDefault) {
      return requestOptions;
    }

    if (auth._authType == AuthorizationType.JWT) {
      if (auth._hasValidatedOnce && !isNullOrEmpty(auth._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${auth._scheme} ${auth._encryptedAccessToken}';
        return requestOptions;
      }

      auth._handleJwtAuthentication(client, callback: callback);

      if (auth._hasValidatedOnce && !isNullOrEmpty(auth._encryptedAccessToken)) {
        requestOptions.headers['Authorization'] = '${auth._scheme} ${auth._encryptedAccessToken}';
      }

      return requestOptions;
    }

    requestOptions.headers['Authorization'] = '${auth._scheme} ${auth._encryptedAccessToken}';
    return requestOptions;
  }
}
