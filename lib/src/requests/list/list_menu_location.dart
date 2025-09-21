import '../../../wordpress_client.dart';

/// List Menu Locations (GET /wp/v2/menu-locations)
final class ListMenuLocationRequest extends IRequest {
  ListMenuLocationRequest({
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
      url: RequestUrl.relative('menu-locations'),
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
