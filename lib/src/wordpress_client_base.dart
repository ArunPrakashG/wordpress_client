import 'dart:convert';

import 'package:dio/dio.dart';

import 'exceptions/null_reference_exception.dart';
import 'requests/builders/request_builder.dart';
import 'requests/request.dart';
import 'responses/post_response.dart';
import 'responses/response_container.dart';
import 'utilities/cookie_container.dart';
import 'utilities/pair.dart';

class WordpressClient {
  Dio _client;
  CookieContainer _cookies;
  String _baseUrl;

  WordpressClient(String baseUrl, {CookieContainer cookieContainer}) {
    _client = Dio(BaseOptions());
    _baseUrl = baseUrl;
    _cookies = cookieContainer ?? CookieContainer();
  }

  WordpressClient withDefaultUserAgent(String userAgent) {
    _client.options.headers['User-Agent'] = userAgent;
    return this;
  }

  WordpressClient withCookieContainer(CookieContainer cookies) {
    _cookies = cookies;
    return this;
  }

  WordpressClient withDefaultRequestHeaders(List<Pair<String, String>> headers) {
    for (final header in headers) {
      _client.options.headers[header.a] = header.b;
    }

    return this;
  }

  Future<ResponseContainer<List<Post>>> fetchPosts(Request Function(RequestBuilder) builder) =>
      _postRequestAsync<List<Post>>(<Post>[], builder(RequestBuilder()));

  Future<ResponseContainer<T>> _postRequestAsync<T>(T instance, Request request) async {
    if (request == null || request.requestUri == null) {
      return null;
    }

    var watch = Stopwatch()..start();
    try {
      final response = await _client.fetch(_parseAsDioRequest(request));
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
        request.callback.responseCallback(jsonDecode(response.data as String));
      }

      if (request.validationDelegate != null && !request.validationDelegate(jsonDecode(response.data as String))) {
        return ResponseContainer<T>.failed(
          null,
          duration: watch.elapsed,
          errorMessage: 'Request abort by user in validationDelegate()',
          status: false,
          responseCode: response.statusCode,
        );
      }

      return ResponseContainer<T>(
        jsonDecode(response.data),
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

  RequestOptions _parseAsDioRequest(Request request) {
    if (request == null) {
      throw NullReferenceException('Request object is null');
    }

    RequestOptions options = RequestOptions(
      path: request.endpoint,
      method: request.httpMethod.toString().split('.').last,
      baseUrl: request.requestUri.toString(),
      cancelToken: request.cancelToken,
    );

    for (final pair in request.headers) {
      options.headers[pair.a] = pair.b;
    }

    if (request.formBody != null) {
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
