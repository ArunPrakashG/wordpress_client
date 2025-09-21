import '../../../wordpress_client.dart';

/// Render a block on server (wp/v2/block-renderer/<name>)
final class RenderBlockRequest extends IRequest {
  RenderBlockRequest({
    required this.name,
    this.context = RequestContext.edit,
    this.attributes,
    this.postId,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  final String name;
  RequestContext? context;
  Map<String, dynamic>? attributes;
  int? postId;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('attributes', attributes)
      ..addIfNotNull('post_id', postId)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('block-renderer/$name'),
      requireAuth: requireAuth || context == RequestContext.edit,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
