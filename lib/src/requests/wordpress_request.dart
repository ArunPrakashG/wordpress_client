import 'package:dio/dio.dart';

import '../../wordpress_client.dart';
import '../constants.dart';

/// Represents a request to the WordPress REST API.
///
/// This class encapsulates all the necessary information for making a request
/// to the WordPress REST API, including the URL, method, headers, and other
/// configuration options.
final class WordpressRequest {
  /// Creates a new [WordpressRequest] instance.
  ///
  /// [url] and [method] are required parameters. All other parameters are optional.
  const WordpressRequest({
    required this.url,
    required this.method,
    this.headers,
    this.queryParameters,
    this.body,
    this.events,
    this.cancelToken,
    this.requireAuth = false,
    this.authorization,
    this.validator,
    this.sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    this.receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    this.extra = const <String, dynamic>{},
    this.retryPolicy,
  });

  /// [extra] key (on responses) holding how many tries the request needed.
  static const String metaAttempts = 'wp.request.attempts';

  /// [extra] key holding the lower-case HTTP method name (`get`, `post`, ...).
  ///
  /// Filled in by the client before middlewares run. It is never sent to the server.
  static const String metaMethod = 'wp.request.method';

  /// [extra] key holding the fully resolved request URL (without the query string).
  static const String metaUrl = 'wp.request.url';

  /// [extra] key holding the sorted, `&`-joined query string of the request.
  static const String metaQuery = 'wp.request.query';

  /// The URL for the request.
  final RequestUrl url;

  /// The HTTP method for the request (e.g., GET, POST, PUT, DELETE).
  final HttpMethod method;

  /// Optional headers to be included with the request.
  final Map<String, dynamic>? headers;

  /// Optional query parameters to be appended to the URL.
  final Map<String, dynamic>? queryParameters;

  /// The body of the request, typically used for POST or PUT requests.
  final dynamic body;

  /// Indicates whether this request requires authentication.
  final bool requireAuth;

  /// A token that can be used to cancel the request.
  final CancelToken? cancelToken;

  /// The authorization instance to be used for this request, if required.
  final IAuthorization? authorization;

  /// The timeout duration for sending the request.
  final Duration sendTimeout;

  /// The timeout duration for receiving the response.
  final Duration receiveTimeout;

  /// An optional [WordpressEvents] instance for handling request lifecycle events.
  final WordpressEvents? events;

  /// An optional callback function for custom validation of the response.
  final ValidatorCallback? validator;

  /// Local metadata attached to this request.
  ///
  /// Unlike [headers], this is never sent to the server. It is visible to
  /// middlewares and is copied onto the resulting response's `extra`.
  /// See [metaMethod], [metaUrl] and [metaQuery] for the keys the client sets.
  final Map<String, dynamic> extra;

  /// Overrides the client's [RetryPolicy] for this request.
  ///
  /// Pass [RetryPolicy.none] to disable retries for a single request.
  final RetryPolicy? retryPolicy;

  /// Indicates whether this request has associated events.
  bool get hasEvents => events != null;

  /// Indicates whether this request has a custom validator.
  bool get hasValidator => validator != null;

  /// Indicates whether this request has an associated authorization module.
  bool get hasAuthorization => authorization != null;

  /// Creates a copy of this [WordpressRequest] with the given fields replaced with new values.
  ///
  /// This method is useful for modifying a request while keeping the original intact.
  WordpressRequest copyWith({
    RequestUrl? url,
    HttpMethod? method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    WordpressEvents? events,
    CancelToken? cancelToken,
    bool? requireAuth,
    IAuthorization? authorization,
    ValidatorCallback? validator,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? extra,
    RetryPolicy? retryPolicy,
  }) {
    return WordpressRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      body: body ?? this.body,
      events: events ?? this.events,
      cancelToken: cancelToken ?? this.cancelToken,
      requireAuth: requireAuth ?? this.requireAuth,
      authorization: authorization ?? this.authorization,
      validator: validator ?? this.validator,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      extra: extra ?? this.extra,
      retryPolicy: retryPolicy ?? this.retryPolicy,
    );
  }
}
