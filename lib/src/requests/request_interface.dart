// ignore_for_file: comment_references

import 'dart:async';

import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

/// Base class of all requests.
abstract base class IRequest {
  /// Creates a new instance of [IRequest].
  const IRequest({
    this.requireAuth = true,
    this.cancelToken,
    this.authorization,
    this.sendTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.events,
    this.validator,
    this.extra,
    this.headers,
    this.queryParameters,
  });

  /// The extra headers to send with the request.
  final Map<String, String>? headers;

  /// The query parameters to send with the request.
  final Map<String, dynamic>? queryParameters;

  /// Whether the request requires authentication.
  final bool requireAuth;

  /// The cancel token to cancel the request.
  final CancelToken? cancelToken;

  /// The authorization to use for the request.
  final IAuthorization? authorization;

  /// The timeout duration for sending the request.
  final Duration sendTimeout;

  /// The timeout duration for receiving the response.
  final Duration receiveTimeout;

  /// The events to listen to.
  final WordpressEvents? events;

  /// The validator to validate the response.
  final ValidatorCallback? validator;

  /// Allows you to pass custom key value pairs with the requests.
  ///
  /// Eg: meta fields
  /// ```
  /// <String, dynamic>{
  ///   'meta': <String, dynamic>{
  ///     'footnotes': '',
  ///   },
  /// }
  /// ```
  final Map<String, dynamic>? extra;

  /// Builds the request content.
  ///
  /// This method is invoked when the request is ready to be send.
  ///
  /// Request body, headers and other request properties are set on the returning instance.
  ///
  /// Consider using [addIfNotNull] extension method to add a value to a map if it is not null.
  FutureOr<WordpressRequest> build(Uri baseUrl);

  String operator [](String key) {
    if (queryParameters != null) {
      return queryParameters![key] as String? ?? '';
    }

    if (headers != null) {
      return headers![key] ?? '';
    }

    return '';
  }
}
