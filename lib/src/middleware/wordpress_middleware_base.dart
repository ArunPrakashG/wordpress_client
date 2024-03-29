import 'dart:async';

import '../library_exports.dart';
import 'models/middleware_raw_response.dart';

abstract base class IWordpressMiddleware {
  const IWordpressMiddleware();

  String get name;

  Future<void> onLoad();
  Future<WordpressRequest> onRequest(WordpressRequest request);

  Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
    return MiddlewareRawResponse.defaultInstance();
  }

  Future<WordpressRawResponse> onResponse(WordpressRawResponse response);
  Future<void> onUnload();
}
