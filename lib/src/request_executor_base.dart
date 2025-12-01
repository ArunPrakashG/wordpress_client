import 'dart:async';

import 'package:meta/meta.dart';

import 'library_exports.dart';
import 'responses/wordpress_error.dart';
import 'utilities/codable_map/codable_map.dart';

/// Base class for request executors in the WordPress API client.
///
/// This class provides the core functionality for executing requests,
/// handling middleware, and processing responses.
abstract base class IRequestExecutor {
  /// The base URL for the WordPress API.
  Uri get baseUrl;

  /// The list of middleware to be applied to requests and responses.
  Iterable<IWordpressMiddleware> get middlewares;

  /// Configures the executor with the given bootstrap configuration.
  ///
  /// This method should be called before making any requests.
  ///
  /// [configuration] The configuration to apply.
  void configure(BootstrapConfiguration configuration);

  /// Applies request middleware to the given request.
  ///
  /// [request] The original request.
  /// [middlewares] The list of middleware to apply.
  ///
  /// Returns the modified request after applying all middleware.
  Future<WordpressRequest> _handleRequestMiddlewares({
    required WordpressRequest request,
    required Iterable<IWordpressMiddleware> middlewares,
  }) async {
    return middlewares.foldAsync(
      request,
      (r, m) async => m.onRequest(r),
    );
  }

  /// Applies response middleware to the given response.
  ///
  /// [middlewares] The list of middleware to apply.
  /// [response] The original response.
  ///
  /// Returns the modified response after applying all middleware.
  Future<WordpressRawResponse> _handleResponseMiddlewares({
    required Iterable<IWordpressMiddleware> middlewares,
    required WordpressRawResponse response,
  }) async {
    return middlewares.foldAsync(
      response,
      (r, m) async => m.onResponse(r),
    );
  }

  /// Executes a raw request and returns the response.
  ///
  /// This method applies middleware, executes the request, and handles errors.
  ///
  /// [request] The request to execute.
  ///
  /// Returns a [WordpressRawResponse] containing the raw response data.
  @internal
  Future<WordpressRawResponse> raw(WordpressRequest request) async {
    return guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(request),
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );
  }

  /// Creates a new resource using the given request.
  ///
  /// This method is used for POST requests to create new items in the WordPress API.
  ///
  /// [request] The request containing the data for the new resource.
  ///
  /// Returns a [WordpressResponse] with the created item of type [T].
  @internal
  Future<WordpressResponse<T>> create<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(request),
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          rawData: response.data,
          headers: response.headers,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  /// Retrieves a resource using the given request.
  ///
  /// This method is used for GET requests to fetch existing items from the WordPress API.
  ///
  /// [request] The request specifying the resource to retrieve.
  ///
  /// Returns a [WordpressResponse] with the retrieved item of type [T].
  @internal
  Future<WordpressResponse<T>> retrive<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(request),
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<T>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          rawData: response.data,
          headers: response.headers,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse<T>(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  /// Deletes a resource using the given request.
  ///
  /// This method is used for DELETE requests to remove items from the WordPress API.
  ///
  /// [request] The request specifying the resource to delete.
  ///
  /// Returns a [WordpressResponse] with a boolean indicating success or failure.
  @internal
  Future<WordpressResponse<bool>> delete(
    WordpressRequest request,
  ) async {
    final rawResponse = await guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(request),
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map(
      onSuccess: (response) {
        return WordpressSuccessResponse(
          data: true,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  /// Retrieves a list of resources using the given request.
  ///
  /// This method is used for GET requests to fetch multiple items from the WordPress API.
  ///
  /// [request] The request specifying the resources to list.
  ///
  /// Returns a [WordpressResponse] with a list of items of type [T].
  @internal
  Future<WordpressResponse<List<T>>> list<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        final response = await execute(request);

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: response,
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map<List<T>>(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = (response.data as Iterable<dynamic>).map(decoder).toList();

        return WordpressSuccessResponse<List<T>>(
          data: data,
          code: response.code,
          extra: response.extra,
          rawData: response.data,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          message: response.message,
        );
      },
    );
  }

  /// Updates an existing resource using the given request.
  ///
  /// This method is used for PUT or PATCH requests to modify existing items in the WordPress API.
  ///
  /// [request] The request containing the updated data for the resource.
  ///
  /// Returns a [WordpressResponse] with the updated item of type [T].
  @internal
  Future<WordpressResponse<T>> update<T>(
    WordpressRequest request,
  ) async {
    final rawResponse = await guardAsync<WordpressRawResponse>(
      function: () async {
        request = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(request),
        );
      },
      onError: (error, stackTrace) async {
        final isMiddlewareAbortedException =
            error is MiddlewareAbortedException;

        return WordpressRawResponse(
          data: null,
          code: isMiddlewareAbortedException
              ? -RequestErrorType.middlewareAborted.index
              : -RequestErrorType.internalGenericError.index,
          extra: <String, dynamic>{
            'error': error,
            'stackTrace': stackTrace,
          },
          message: isMiddlewareAbortedException
              ? error.message
              : '$error\n\n$stackTrace',
        );
      },
    );

    return rawResponse.map(
      onSuccess: (response) {
        final decoder = CodableMap.getDecoder<T>();
        final data = decoder(response.data);

        return WordpressSuccessResponse<T>(
          data: data,
          code: response.code,
          extra: response.extra,
          rawData: response.data,
          requestHeaders: response.requestHeaders,
          headers: response.headers,
          duration: response.duration,
          message: response.message,
        );
      },
      onFailure: (response) {
        final error = mapGuarded(
          mapper: WordpressError.fromMap,
          json: response.data,
        );

        return WordpressFailureResponse(
          error: error,
          code: response.code,
          headers: response.headers,
          rawData: response.data,
          duration: response.duration,
          extra: response.extra,
          requestHeaders: response.requestHeaders,
          message: response.message,
        );
      },
    );
  }

  /// Executes the given [request] on the associated base URL and returns the result in raw format.
  ///
  /// This method should be implemented by subclasses to perform the actual HTTP request.
  ///
  /// [request] The request to execute.
  ///
  /// Returns a [WordpressRawResponse] containing the raw response data.
  @internal
  Future<WordpressRawResponse> execute(WordpressRequest request);
}
