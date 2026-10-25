import 'dart:async';

import 'package:dio/dio.dart' show DioException, DioExceptionType;
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

  /// The encoders and decoders registered with the owning client.
  CodableMap get codableMap;

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

  /// Runs [request] through request middlewares, [execute] and response
  /// middlewares. Never throws: any error becomes a failure response.
  Future<WordpressRawResponse> _pipeline(WordpressRequest request) {
    return guardAsync<WordpressRawResponse>(
      function: () async {
        final processed = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: await execute(processed),
        );
      },
      onError: (error, stackTrace) async {
        final extra = <String, dynamic>{
          'error': error,
          'stackTrace': stackTrace,
        };

        if (error is MiddlewareAbortedException) {
          return WordpressRawResponse(
            data: null,
            code: -RequestErrorType.middlewareAborted.index,
            extra: extra,
            message: error.message,
          );
        }

        if (error is DioException) {
          final type = switch (error.type) {
            DioExceptionType.cancel => RequestErrorType.requestCancelled,
            DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout =>
              RequestErrorType.timeout,
            DioExceptionType.connectionError ||
            DioExceptionType.badCertificate =>
              RequestErrorType.connectionFailed,
            DioExceptionType.badResponse ||
            DioExceptionType.unknown =>
              RequestErrorType.internalGenericError,
          };

          if (type != RequestErrorType.internalGenericError) {
            return WordpressRawResponse(
              data: null,
              code: -type.index,
              extra: extra,
              message: error.message ?? error.type.name,
            );
          }

          // Dio could not parse a body that claims to be JSON (for example a
          // PHP notice printed before the payload).
          if (error.error is FormatException) {
            return WordpressRawResponse(
              data: null,
              code: -RequestErrorType.invalidResponse.index,
              extra: <String, dynamic>{...extra, 'error': error.error},
              message: 'The response body is not valid JSON: ${error.error}',
            );
          }
        }

        return WordpressRawResponse(
          data: null,
          code: -RequestErrorType.internalGenericError.index,
          extra: extra,
          message: '$error\n\n$stackTrace',
        );
      },
    );
  }

  /// Converts [raw] into a typed response.
  ///
  /// Successful payloads go through [decode]. If decoding throws, the result is
  /// a [WordpressFailureResponse] with [RequestErrorType.invalidResponse]
  /// that keeps the raw payload, the exception and its stack trace.
  WordpressResponse<T> _toResponse<T>(
    WordpressRawResponse raw,
    T Function(dynamic data) decode,
  ) {
    if (raw.isFailure) {
      return WordpressFailureResponse<T>(
        error: mapGuarded(
          mapper: WordpressError.fromMap,
          json: raw.data,
        ),
        code: raw.code,
        rawData: raw.data,
        headers: raw.headers,
        duration: raw.duration,
        extra: raw.extra,
        requestHeaders: raw.requestHeaders,
        message: raw.message,
      );
    }

    final T data;

    try {
      data = decode(raw.data);
    } catch (error, stackTrace) {
      return WordpressFailureResponse<T>(
        error: null,
        code: -RequestErrorType.invalidResponse.index,
        rawData: raw.data,
        headers: raw.headers,
        duration: raw.duration,
        requestHeaders: raw.requestHeaders,
        extra: <String, dynamic>{
          ...raw.extra,
          'error': error,
          'stackTrace': stackTrace,
          'statusCode': raw.code,
        },
        message: 'Failed to decode the response body as $T '
            '(HTTP ${raw.code}): $error',
      );
    }

    return WordpressSuccessResponse<T>(
      data: data,
      code: raw.code,
      rawData: raw.data,
      extra: raw.extra,
      requestHeaders: raw.requestHeaders,
      headers: raw.headers,
      duration: raw.duration,
      message: raw.message,
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
  Future<WordpressRawResponse> raw(WordpressRequest request) {
    return _pipeline(request);
  }

  /// Creates a new resource using the given request.
  ///
  /// This method is used for POST requests to create new items in the WordPress API.
  ///
  /// [request] The request containing the data for the new resource.
  ///
  /// Returns a [WordpressResponse] with the created item of type [T].
  @internal
  Future<WordpressResponse<T>> create<T>(WordpressRequest request) async {
    return _toResponse<T>(
      await _pipeline(request),
      (data) => codableMap.getDecoder<T>()(data),
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
  Future<WordpressResponse<T>> retrieve<T>(WordpressRequest request) async {
    return _toResponse<T>(
      await _pipeline(request),
      (data) => codableMap.getDecoder<T>()(data),
    );
  }

  /// Misspelled alias of [retrieve].
  @internal
  @Deprecated('Use retrieve instead. Will be removed in 11.0.0.')
  Future<WordpressResponse<T>> retrive<T>(WordpressRequest request) {
    return retrieve<T>(request);
  }

  /// Deletes a resource using the given request.
  ///
  /// This method is used for DELETE requests to remove items from the WordPress API.
  ///
  /// [request] The request specifying the resource to delete.
  ///
  /// Returns a [WordpressResponse] with a boolean indicating success or failure.
  @internal
  Future<WordpressResponse<bool>> delete(WordpressRequest request) async {
    return _toResponse<bool>(await _pipeline(request), (_) => true);
  }

  /// Retrieves a list of resources using the given request.
  ///
  /// This method is used for GET requests to fetch multiple items from the WordPress API.
  ///
  /// [request] The request specifying the resources to list.
  ///
  /// Returns a [WordpressResponse] with a list of items of type [T]. A
  /// successful status code with a body that is not a JSON array (an HTML
  /// error page or a PHP notice, for instance) yields a failure response.
  @internal
  Future<WordpressResponse<List<T>>> list<T>(WordpressRequest request) async {
    return _toResponse<List<T>>(
      await _pipeline(request),
      (data) {
        if (data is! Iterable<dynamic>) {
          throw FormatException(
            'Expected a JSON array but received ${data.runtimeType}.',
          );
        }

        final decoder = codableMap.getDecoder<T>();

        return data.map(decoder).toList();
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
  Future<WordpressResponse<T>> update<T>(WordpressRequest request) async {
    return _toResponse<T>(
      await _pipeline(request),
      (data) => codableMap.getDecoder<T>()(data),
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
