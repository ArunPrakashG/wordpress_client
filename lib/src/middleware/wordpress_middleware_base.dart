import 'dart:async';

import '../library_exports.dart';

/// The base interface for WordPress middleware.
///
/// Middleware allows you to intercept and modify requests and responses
/// in the WordPress API client. This can be useful for tasks such as
/// authentication, caching, logging, or modifying request/response data.
abstract class IWordpressMiddleware {
  const IWordpressMiddleware();

  /// The name of the middleware.
  ///
  /// This should be a unique identifier for the middleware.
  /// Example: 'AuthenticationMiddleware'
  String get name;

  /// Called when the middleware is loaded.
  ///
  /// Use this method to initialize any resources needed by the middleware.
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   await _initializeCache();
  /// }
  /// ```
  Future<void> onLoad();

  /// Called before sending a request to the WordPress server.
  ///
  /// This method allows you to modify the outgoing request.
  /// Example: Adding an authentication token to the request headers
  /// ```dart
  /// @override
  /// Future<WordpressRequest> onRequest(WordpressRequest request) async {
  ///   return request.copyWith(
  ///     headers: {...request.headers, 'Authorization': 'Bearer $token'},
  ///   );
  /// }
  /// ```
  Future<WordpressRequest> onRequest(WordpressRequest request);

  /// Called before executing a request to the WordPress server.
  ///
  /// This method can be used to return a custom response (e.g., a cached response)
  /// or to cancel the request by throwing an exception.
  ///
  /// By default, it returns a [MiddlewareRawResponse] with default values.
  ///
  /// Example: Returning a cached response
  /// ```dart
  /// @override
  /// Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
  ///   final cachedResponse = await _cache.get(request.url);
  ///   if (cachedResponse != null) {
  ///     return MiddlewareRawResponse(
  ///       statusCode: 200,
  ///       body: cachedResponse,
  ///       headers: {'X-Cache': 'HIT'},
  ///     );
  ///   }
  ///   return MiddlewareRawResponse.defaultInstance();
  /// }
  /// ```
  Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
    return MiddlewareRawResponse.defaultInstance();
  }

  /// Called after receiving a response from the WordPress server.
  ///
  /// This method allows you to modify or process the incoming response.
  /// Example: Logging the response
  /// ```dart
  /// @override
  /// Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
  ///   _logger.info('Received response: ${response.statusCode}');
  ///   return response;
  /// }
  /// ```
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response);

  /// Called when the middleware is unloaded.
  ///
  /// Use this method to clean up any resources used by the middleware.
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onUnload() async {
  ///   await _closeConnections();
  /// }
  /// ```
  Future<void> onUnload();
}
