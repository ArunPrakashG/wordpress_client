import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:meta/meta.dart';

import 'library_exports.dart';
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

  /// Whether identical in-flight `GET` requests share one network call.
  bool get deduplicateRequests;

  /// Maximum number of requests running at once, or `null` for no limit.
  int? get maxConcurrentRequests;

  final Map<String, Future<WordpressRawResponse>> _inFlight =
      <String, Future<WordpressRawResponse>>{};
  final Queue<Completer<void>> _waiting = Queue<Completer<void>>();
  int _running = 0;

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
  ///
  /// Fires [WordpressEvents.onCancel] / [WordpressEvents.onError] once the
  /// final response is known.
  Future<WordpressRawResponse> _pipeline(WordpressRequest request) {
    final key = deduplicateRequests ? _dedupeKey(request) : null;
    if (key == null) {
      return _limited(request);
    }

    // Callers share the response object; it is never mutated after creation.
    final existing = _inFlight[key];
    if (existing != null) {
      return existing;
    }

    // A block body: whenComplete would await the future `remove` returns,
    // which is this very future.
    final future = _limited(request).whenComplete(() {
      _inFlight.remove(key);
    });
    _inFlight[key] = future;
    return future;
  }

  /// Key under which identical concurrent requests are shared, or `null` when
  /// [request] must not be shared.
  String? _dedupeKey(WordpressRequest request) {
    if (request.method != HttpMethod.get ||
        request.cancelToken != null ||
        request.events != null) {
      return null;
    }

    final query = <String>[
      for (final e
          in (request.queryParameters ?? const <String, dynamic>{}).entries)
        '${e.key}=${e.value}',
    ]..sort();
    final headers = <String>[
      for (final e in (request.headers ?? const <String, dynamic>{}).entries)
        '${e.key.toLowerCase()}:${e.value}',
    ]..sort();

    return [
      request.url.toString(),
      query.join('&'),
      headers.join('|'),
      '${request.authorization == null ? 0 : identityHashCode(request.authorization)}',
      '${request.requireAuth}',
    ].join('\n');
  }

  Future<WordpressRawResponse> _limited(WordpressRequest request) async {
    final limit = maxConcurrentRequests;
    if (limit == null) {
      return _tracked(request);
    }

    if (_running >= limit) {
      final turn = Completer<void>();
      _waiting.add(turn);
      await turn.future;
    } else {
      _running++;
    }

    try {
      return await _tracked(request);
    } finally {
      if (_waiting.isNotEmpty) {
        // Hand the slot straight to the next waiter.
        _waiting.removeFirst().complete();
      } else {
        _running--;
      }
    }
  }

  Future<WordpressRawResponse> _tracked(WordpressRequest request) async {
    final raw = await _runPipeline(request);
    _notifyEvents(request, raw);
    return raw;
  }

  void _notifyEvents(WordpressRequest request, WordpressRawResponse raw) {
    final events = request.events;
    if (events == null || raw.isSuccessful) {
      return;
    }

    try {
      if (raw.code == -RequestErrorType.requestCancelled.index) {
        events.onCancel?.call();
        return;
      }

      final onError = events.onError;
      if (onError == null) {
        return;
      }

      final parsed = mapGuarded(mapper: WordpressError.fromMap, json: raw.data);
      onError(
        parsed ??
            WordpressError(
              code: raw.code < 0 && -raw.code < RequestErrorType.values.length
                  ? RequestErrorType.values[-raw.code].name
                  : 'http_${raw.code}',
              message: raw.message,
              status: raw.code > 0 ? raw.code : null,
            ),
      );
    } catch (_) {
      // A throwing user callback must not break the request pipeline.
    }
  }

  Future<WordpressRawResponse> _runPipeline(WordpressRequest request) {
    // The request as the middlewares left it, so failures keep its metadata.
    var latest = request;

    return guardAsync<WordpressRawResponse>(
      function: () async {
        final processed = await _handleRequestMiddlewares(
          request: request,
          middlewares: middlewares,
        );
        latest = processed;

        // A transport failure is an ordinary response to the response
        // middlewares, so they can log it or react to it.
        WordpressRawResponse raw;
        try {
          raw = await execute(processed);
        } catch (error, stackTrace) {
          raw = _failure(processed, error, stackTrace);
        }

        return _handleResponseMiddlewares(
          middlewares: middlewares,
          response: raw,
        );
      },
      onError: (error, stackTrace) async => _failure(latest, error, stackTrace),
    );
  }

  /// The failure response for [error], carrying [request]'s extra.
  WordpressRawResponse _failure(
    WordpressRequest request,
    Object error,
    StackTrace stackTrace,
  ) {
    final extra = <String, dynamic>{
      ...request.extra,
      // The options Dio was given carry the request metadata (method, URL).
      if (error is DioException) ...error.requestOptions.extra,
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
      // Not an exhaustive switch: newer Dio versions add enum members
      // (for example transformTimeout), which would break compilation.
      final dioType = error.type;
      final RequestErrorType type;
      if (dioType == DioExceptionType.cancel) {
        type = RequestErrorType.requestCancelled;
      } else if (dioType == DioExceptionType.connectionTimeout ||
          dioType == DioExceptionType.sendTimeout ||
          dioType == DioExceptionType.receiveTimeout) {
        type = RequestErrorType.timeout;
      } else if (dioType == DioExceptionType.connectionError ||
          dioType == DioExceptionType.badCertificate) {
        type = RequestErrorType.connectionFailed;
      } else {
        type = RequestErrorType.internalGenericError;
      }

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
