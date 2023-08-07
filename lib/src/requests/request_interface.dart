// ignore_for_file: comment_references

import 'dart:async';

import '../../wordpress_client.dart';
import '../utilities/typedefs.dart';

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
  });

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

  /// Builds the request content.
  ///
  /// This method is invoked when the request is ready to be send.
  ///
  /// Request body, headers and other request properties are set on the returning instance.
  ///
  /// Consider using [addIfNotNull] extension method to add a value to a map if it is not null.
  FutureOr<WordpressRequest> build(Uri baseUrl);
}
