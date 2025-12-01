import '../../../wordpress_client.dart';

/// Retrieve a Nav Menu Item (GET /wp/v2/menu-items/<id>)
final class RetrieveNavMenuItemRequest extends IRequest {
  RetrieveNavMenuItemRequest({
    required this.id,
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

  int id;
  RequestContext? context;

  @override
  WordpressRequest build(Uri baseUrl) {
    final qp = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      queryParameters: qp,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['menu-items', id]),
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
