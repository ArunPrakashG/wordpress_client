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

final class DelegatedMiddleware extends IWordpressMiddleware {
  const DelegatedMiddleware({
    required this.onRequestDelegate,
    required this.onResponseDelegate,
    this.initializeDelegate,
    this.onRemovedDelegate,
  });

  final InitializeDelegate? initializeDelegate;
  final OnRequestDelegate onRequestDelegate;
  final OnResponseDelegate onResponseDelegate;
  final OnRemovedDelegate? onRemovedDelegate;

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
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    return onResponseDelegate(response);
  }

  @override
  Future<void> onUnload() async {
    await onRemovedDelegate?.call();
  }
}
