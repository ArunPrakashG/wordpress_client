import '../requests/wordpress_request.dart';
import '../responses/wordpress_raw_response.dart';
import 'middleware_exports.dart';

typedef OnRequestDelegate = Future<WordpressRequest> Function(
  WordpressRequest request,
);

typedef OnResponseDelegate = Future<WordpressRawResponse> Function(
  WordpressRawResponse response,
);

typedef InitializeDelegate = Future<void> Function();
typedef OnRemovedDelegate = Future<void> Function();
typedef OnExecuteDelegate = Future<MiddlewareRawResponse> Function(
  WordpressRequest request,
);

final class DelegatedMiddleware extends IWordpressMiddleware {
  const DelegatedMiddleware({
    required this.onRequestDelegate,
    required this.onResponseDelegate,
    this.initializeDelegate,
    this.onExecuteDelegate,
    this.onRemovedDelegate,
  });

  final InitializeDelegate? initializeDelegate;
  final OnRequestDelegate onRequestDelegate;
  final OnResponseDelegate onResponseDelegate;
  final OnRemovedDelegate? onRemovedDelegate;
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
