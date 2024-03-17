import 'package:dio/dio.dart';

import '../../wordpress_client.dart';
import '../constants.dart';

/// Represents a request to the Wordpress REST API.
final class WordpressRequest {
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
    this.sendTimeout = kDefaultRequestTimeout,
    this.receiveTimeout = kDefaultRequestTimeout,
  });

  /// The request url.
  final RequestUrl url;

  /// The request method.
  final HttpMethod method;

  /// The request headers.
  final Map<String, dynamic>? headers;

  /// The request query parameters.
  final Map<String, dynamic>? queryParameters;

  /// The request body.
  final dynamic body;

  /// Specifies if this request requires authentication.
  final bool requireAuth;

  /// The cancel token.
  final CancelToken? cancelToken;

  /// The authorization instance.
  final IAuthorization? authorization;

  /// The request send timeout.
  final Duration sendTimeout;

  /// The request receive timeout.
  final Duration receiveTimeout;

  /// The events instance.
  final WordpressEvents? events;

  /// The validator callback.
  final ValidatorCallback? validator;

  /// Gets if this request has events.
  bool get hasEvents => events != null;

  /// Gets if this request has a validator overload.
  bool get hasValidator => validator != null;

  /// Gets if this request has a authorization module.
  bool get hasAuthorization => authorization != null;

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
    );
  }
}
