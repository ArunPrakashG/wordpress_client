import 'dart:convert';

import 'package:dio/dio.dart';

import 'enums.dart';
import 'exceptions/authorization_failed_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'requests/request.dart';
import 'responses/response_container.dart';
import 'utilities/cookie_container.dart';
import 'utilities/helpers.dart';
import 'utilities/pair.dart';
import 'wordpress_authorization.dart';

const int defaultRequestTimeout = 60;

class InternalRequester {
  Dio _client;
  String _baseUrl;
  WordpressAuthorization _defaultAuthorization;
  bool Function(dynamic) _responsePreprocessorDelegate;

  InternalRequester(String baseUrl, String path, {CookieContainer cookieContainer}) {
    if (baseUrl == null) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (path == null) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    _baseUrl = parseUrl(baseUrl, path);

    _client = Dio(
      BaseOptions(
        connectTimeout: defaultRequestTimeout,
        receiveTimeout: defaultRequestTimeout,
        followRedirects: true,
        maxRedirects: 5,
        baseUrl: _baseUrl,
      ),
    );
  }

  InternalRequester withDefaultUserAgent(String userAgent) {
    _client.options.headers['User-Agent'] = userAgent;
    return this;
  }

  Future<InternalRequester> withDefaultAuthorization(WordpressAuthorization auth) async {
    if (auth == null || auth.isDefault) {
      return this;
    }

    if (_defaultAuthorization != null && !_defaultAuthorization.isDefault) {
      return this;
    }

    _defaultAuthorization = auth;
    var encryptedAccessToken = null;
    if (!_defaultAuthorization.isValidAuth &&
        _defaultAuthorization.authType == AuthorizationType.JWT &&
        !await _defaultAuthorization.handleJwtAuthentication(_client, (token) {
          encryptedAccessToken = token;
        })) {
      return this;
    }

    if (!isNullOrEmpty(encryptedAccessToken)) {
      _client.options.headers['Authorization'] = '${_defaultAuthorization.scheme} $encryptedAccessToken';
    }

    return this;
  }

  InternalRequester withGlobalResponsePreprocessorDelegate(bool Function(dynamic) delgate) {
    _responsePreprocessorDelegate = delgate;
    return this;
  }

  InternalRequester withDefaultRequestHeaders(List<Pair<String, String>> headers) {
    for (final header in headers) {
      _client.options.headers[header.key] = header.value;
    }

    return this;
  }

  Future<ResponseContainer<T>> requestAsync<T>(Request request) async {
    if (request == null || isNullOrEmpty(request.generatedRequestPath)) {
      return null;
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

      if (_responsePreprocessorDelegate != null && !_responsePreprocessorDelegate(response.data)) {
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

      if (request.validationDelegate != null && !request.validationDelegate(jsonDecode(response.data))) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request aborted by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<T>(
        response.data,
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
