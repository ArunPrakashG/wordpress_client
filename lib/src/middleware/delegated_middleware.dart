import '../requests/wordpress_request.dart';
import '../responses/wordpress_raw_response.dart';
import 'middleware_exports.dart';

/// A function type for modifying a WordPress request before it's sent.
typedef OnRequestDelegate = Future<WordpressRequest> Function(
  WordpressRequest request,
);

/// A function type for processing a WordPress response after it's received.
typedef OnResponseDelegate = Future<WordpressRawResponse> Function(
  WordpressRawResponse response,
);

/// A function type for initializing the middleware.
typedef InitializeDelegate = Future<void> Function();

/// A function type for cleaning up when the middleware is removed.
typedef OnRemovedDelegate = Future<void> Function();

/// A function type for custom execution logic in the middleware.
typedef OnExecuteDelegate = Future<MiddlewareRawResponse> Function(
  WordpressRequest request,
);

/// A middleware that delegates its functionality to provided functions.
///
/// This allows for flexible and customizable middleware behavior without
/// needing to create a new class for each variation.
final class DelegatedMiddleware extends IWordpressMiddleware {
  /// Creates a new [DelegatedMiddleware] instance.
  ///
  /// [onRequestDelegate] and [onResponseDelegate] are required.
  /// Other delegates are optional and will only be called if provided.
  const DelegatedMiddleware({
    required this.onRequestDelegate,
    required this.onResponseDelegate,
    this.initializeDelegate,
    this.onExecuteDelegate,
    this.onRemovedDelegate,
  });

  /// Called when the middleware is loaded.
  final InitializeDelegate? initializeDelegate;

  /// Called for each request passing through the middleware.
  final OnRequestDelegate onRequestDelegate;

  /// Called for each response passing through the middleware.
  final OnResponseDelegate onResponseDelegate;

  /// Called when the middleware is removed.
  final OnRemovedDelegate? onRemovedDelegate;

  /// Called for custom execution logic, if provided.
  final OnExecuteDelegate? onExecuteDelegate;

  @override
  Future<void> onLoad() async {
    await initializeDelegate?.call();
  }

  @override
  String get name => 'DelegatedMiddleware${initializeDelegate.hashCode}';

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    return onRequestDelegate(request);
  }

  @override
  Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
    return await onExecuteDelegate?.call(request) ??
        MiddlewareRawResponse.defaultInstance();
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    return onResponseDelegate(response);
  }

  @override
  Future<void> onUnload() async {
    await onRemovedDelegate?.call();
  }
}
