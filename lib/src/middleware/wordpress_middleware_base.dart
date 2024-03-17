import 'dart:async';

import '../library_exports.dart';

abstract base class IWordpressMiddleware {
  const IWordpressMiddleware();

  String get name;

  Future<void> onLoad();
  Future<WordpressRequest> onRequest(WordpressRequest request);
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response);
  Future<void> onUnload();
}
