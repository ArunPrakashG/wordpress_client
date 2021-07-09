import 'dart:io';

import 'package:wordpress_client/src/cookie_container.dart';

class WordpressClient {
  HttpClient _client;
  CookieContainer _cookies;
  List<Map<String, String>> _defaultHeaders;

  WordpressClient({CookieContainer cookieContainer}) {
    _client = HttpClient();
    _client.autoUncompress = true;
    _cookies = cookieContainer ?? CookieContainer();
  }

  WordpressClient withDefaultUserAgent(String userAgent) {
    _client.userAgent = userAgent;
    return this;
  }

  WordpressClient withCookieContainer(CookieContainer cookies) {
    _cookies = cookies;
    return this;
  }

  WordpressClient withDefaultRequestHeaders(List<Map<String, String>> headers) {
    _defaultHeaders = headers;
    return this;
  }
}
