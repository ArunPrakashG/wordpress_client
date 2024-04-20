import 'dart:async';

import '../library_exports.dart';

/// The base interface for WordPress middleware.
abstract class IWordpressMiddleware {
  const IWordpressMiddleware();

  /// The name of the middleware.
  String get name;

  /// Called when the middleware is loaded.
  Future<void> onLoad();

  /// Called before sending a request to the WordPress server.
  Future<WordpressRequest> onRequest(WordpressRequest request);

  /// Called before executing a request to the WordPress server.
  ///
  /// By default, it returns a [MiddlewareRawResponse] with default values.
  ///
  /// This can used for returning a custom response (cached response), or to cancel the request (By throwing an exception).
  Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
    return MiddlewareRawResponse.defaultInstance();
  }

  /// Called after receiving a response from the WordPress server.
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response);

  /// Called when the middleware is unloaded.
  Future<void> onUnload();
}
