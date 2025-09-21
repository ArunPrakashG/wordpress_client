import '../../../wordpress_client.dart';

/// Retrieve a Menu Location (GET /wp/v2/menu-locations/<location>)
final class RetrieveMenuLocationRequest extends IRequest {
  RetrieveMenuLocationRequest({
    required this.location,
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

  String location;
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
      url: RequestUrl.relativeParts(['menu-locations', location]),
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
