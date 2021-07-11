import 'package:dio/dio.dart';

import 'utilities/cookie_container.dart';
import 'requests/builders/request_builder.dart';
import 'requests/request.dart';
import 'responses/post_response.dart';
import 'responses/response_container.dart';
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

  Future<ResponseContainer<List<Post>>> fetchPosts(Request Function(RequestBuilder) builder) async {
    builder(RequestBuilder());
  }

  Future<ResponseContainer<T>> _postRequestAsync<T>(Request request) {
    if (request == null || request.requestUri == null) {
      return null;
    }

    var watch = Stopwatch()..start();
    try {
      _client.fetch(RequestOptions(
        method: request.httpMethod.toString().split('.').last,
        baseUrl: request.requestUri.toString(),
        path: request.endpoint,
      ));
    } on Exception catch (e) {} finally {
      watch.stop();
    }
  }
}
