import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A request captured by [MockWordpressAdapter].
final class RecordedRequest {
  const RecordedRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
  });

  /// Upper-case HTTP method (`GET`, `POST`, ...).
  final String method;

  /// The full resolved request URI, including the query string.
  final Uri uri;

  /// The headers that were actually sent to the server.
  final Map<String, dynamic> headers;

  /// The request body as given to Dio (already JSON-encoded for GraphQL).
  final dynamic body;

  /// The request path, e.g. `/wp-json/wp/v2/posts`.
  String get path => uri.path;

  @override
  String toString() => '$method $uri';
}

/// A canned reply produced by [MockWordpressAdapter].
final class MockResponse {
  const MockResponse({
    this.statusCode = 200,
    this.body,
    this.headers = const {},
    this.delay = Duration.zero,
    this.error,
    this.errorType = DioExceptionType.connectionError,
  });

  /// A WordPress-style JSON error, e.g. `rest_post_invalid_id`.
  factory MockResponse.wpError({
    required int statusCode,
    required String code,
    String message = '',
  }) {
    return MockResponse(
      statusCode: statusCode,
      body: {
        'code': code,
        'message': message,
        'data': {'status': statusCode},
      },
    );
  }

  /// A paginated list response carrying `X-WP-Total` and `X-WP-TotalPages`.
  factory MockResponse.paged(
    List<dynamic> items, {
    required int total,
    required int totalPages,
    Map<String, String> headers = const {},
    Duration delay = Duration.zero,
  }) {
    return MockResponse(
      body: items,
      delay: delay,
      headers: {
        'X-WP-Total': '$total',
        'X-WP-TotalPages': '$totalPages',
        ...headers,
      },
    );
  }

  /// A transport level failure (no HTTP response), e.g. a connection reset.
  factory MockResponse.connectionError([String message = 'Connection reset']) {
    return MockResponse(error: message);
  }

  /// A receive timeout (no HTTP response).
  factory MockResponse.timeout([String message = 'Receive timeout']) {
    return MockResponse(
      error: message,
      errorType: DioExceptionType.receiveTimeout,
    );
  }

  final int statusCode;

  /// Either a [String] (sent verbatim) or any JSON encodable value.
  final dynamic body;
  final Map<String, String> headers;

  /// Artificial latency before the response is delivered.
  final Duration delay;

  /// When set, the adapter throws a [DioException] of [errorType] with this
  /// message instead of answering.
  final String? error;

  /// The kind of [DioException] thrown when [error] is set.
  final DioExceptionType errorType;
}

typedef MockHandler = FutureOr<MockResponse> Function(RecordedRequest request);

/// A Dio [HttpClientAdapter] that serves canned WordPress responses.
///
/// Use it to test code that depends on a `WordpressClient` without a live
/// site:
///
/// ```dart
/// final adapter = MockWordpressAdapter()
///   ..reply('GET', '/posts', const MockResponse(body: [{'id': 1}]));
///
/// final client = WordpressClient.fromDioInstance(
///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
///   instance: Dio()..httpClientAdapter = adapter,
/// );
/// ```
///
/// Routes are matched in registration order; the first match wins. A
/// [String] route matches when the request path ends with it, a [RegExp] is
/// tested against the path. Unmatched requests are recorded and answered
/// with a WordPress style `rest_no_route` 404 (or throw when [strict]).
class MockWordpressAdapter implements HttpClientAdapter {
  MockWordpressAdapter({this.strict = false});

  /// Throw a [StateError] for requests no route matches.
  final bool strict;

  final List<_Route> _routes = [];
  final List<RecordedRequest> _requests = [];

  /// Every request seen so far, in order.
  List<RecordedRequest> get requests => List.unmodifiable(_requests);

  /// Number of requests seen, optionally narrowed by [method] and [path].
  int callCount({String? method, Pattern? path}) {
    return _requests.where((r) {
      if (method != null && r.method != method.toUpperCase()) {
        return false;
      }
      return path == null || _matchesPath(path, r.path);
    }).length;
  }

  /// The most recent request, or null if none was made.
  RecordedRequest? get lastRequest => _requests.isEmpty ? null : _requests.last;

  /// Answers every matching request with [response].
  void reply(String method, Pattern path, MockResponse response) {
    on(method, path, (_) => response);
  }

  /// Answers matching requests with the result of [handler].
  ///
  /// Registering the same method and path again prepends the new route, so
  /// the latest registration wins.
  void on(String method, Pattern path, MockHandler handler) {
    _routes.insert(0, _Route(method.toUpperCase(), path, handler));
  }

  /// Answers matching requests with each of [responses] in turn, repeating
  /// the last one once exhausted. Handy for retry and polling tests.
  void replySequence(
    String method,
    Pattern path,
    List<MockResponse> responses,
  ) {
    assert(responses.isNotEmpty, 'responses must not be empty');
    var index = 0;
    on(method, path, (_) {
      final response = responses[index];
      if (index < responses.length - 1) {
        index++;
      }
      return response;
    });
  }

  /// Forgets recorded requests, keeping the routes.
  void clearRequests() => _requests.clear();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final request = RecordedRequest(
      method: options.method.toUpperCase(),
      uri: options.uri,
      headers: Map<String, dynamic>.of(options.headers),
      body: options.data,
    );
    _requests.add(request);

    final route = _routes
        .where(
          (r) =>
              r.method == request.method && _matchesPath(r.path, request.path),
        )
        .firstOrNull;

    if (route == null) {
      if (strict) {
        throw StateError('No mock route for $request');
      }

      return _toBody(
        MockResponse.wpError(
          statusCode: 404,
          code: 'rest_no_route',
          message: 'No route was found matching the URL and request method.',
        ),
      );
    }

    final response = await route.handler(request);

    if (response.delay > Duration.zero) {
      await Future<void>.delayed(response.delay);
    }

    final error = response.error;
    if (error != null) {
      throw DioException(
        requestOptions: options,
        type: response.errorType,
        message: error,
      );
    }

    return _toBody(response);
  }

  ResponseBody _toBody(MockResponse response) {
    final body = response.body;
    final payload = switch (body) {
      null => '',
      String() => body,
      _ => jsonEncode(body),
    };

    final contentType = body is String ? 'text/plain' : Headers.jsonContentType;

    return ResponseBody.fromString(
      payload,
      response.statusCode,
      headers: {
        // Strings are sent verbatim, so they default to text/plain. Set a
        // Content-Type header to simulate a server that lies about it.
        Headers.contentTypeHeader: [contentType],
        for (final entry in response.headers.entries)
          entry.key.toLowerCase(): [entry.value],
      },
    );
  }

  static bool _matchesPath(Pattern pattern, String path) {
    if (pattern is String) {
      return path.endsWith(pattern);
    }

    return pattern.allMatches(path).isNotEmpty;
  }

  @override
  void close({bool force = false}) {}
}

final class _Route {
  const _Route(this.method, this.path, this.handler);

  final String method;
  final Pattern path;
  final MockHandler handler;
}
