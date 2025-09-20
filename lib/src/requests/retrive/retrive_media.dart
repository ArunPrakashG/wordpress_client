import '../../../wordpress_client.dart';

/// Retrieve a Media Item (GET /wp/v2/media/<id>).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/media/#retrieve-a-media-item
final class RetrieveMediaRequest extends IRequest {
  RetrieveMediaRequest({
    required this.id,
    this.context = RequestContext.view,
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

  RequestContext? context;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addAllIfNotNull(this.queryParameters)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.get,
      headers: headers,
      url: RequestUrl.relativeParts(['media', id]),
      queryParameters: queryParameters,
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
