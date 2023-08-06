// ignore_for_file: comment_references

import 'dart:async';

import '../../wordpress_client.dart';
import '../utilities/typedefs.dart';

/// Base class of all requests.
abstract base class IRequest {
  const IRequest({
    this.requireAuth = true,
    this.cancelToken,
    this.authorization,
    this.sendTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.events,
    this.validator,
  });

  final bool requireAuth;
  final CancelToken? cancelToken;
  final IAuthorization? authorization;
  final Duration sendTimeout;
  final Duration receiveTimeout;
  final WordpressEvents? events;
  final ValidatorCallback? validator;

  /// Builds the request content.
  ///
  /// This method is invoked when the request is ready to be send.
  ///
  /// Request body, headers and other request properties are set by appending on to request content properties.
  ///
  /// Consider using [addIfNotNull] extension method to add a value to a map if it is not null.
  ///
  /// It is not recommended to run functions which takes time to complete in the `build()` method. This can affect entire client performence as this method is invoked from a constructor.

  FutureOr<WordpressRequest> build(Uri baseUrl);
}
