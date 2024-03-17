import 'dart:async';

import '../library_exports.dart';

abstract base class IWordpressMiddleware {
  String get name;

  Future<void> initialize();
  Future<WordpressRequest> onRequest(WordpressRequest request);
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response);
}
