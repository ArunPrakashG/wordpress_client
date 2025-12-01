import '../../../wordpress_client.dart';

final class RetrievePostRevisionRequest extends IRequest {
  RetrievePostRevisionRequest({
    required this.postId,
    required this.revisionId,
    this.context,
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

  /// The ID for the parent of the revision (post ID).
  final int postId;

  /// Unique identifier for the revision.
  final int revisionId;

  /// Scope under which the request is made; determines fields present in response.
  /// One of: view, embed, edit.
  RequestContext? context;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('posts/$postId/revisions/$revisionId'),
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
