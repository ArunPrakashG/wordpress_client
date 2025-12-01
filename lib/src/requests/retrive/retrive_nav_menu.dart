import '../../../wordpress_client.dart';

/// Retrieve a Nav_Menu by id
final class RetrieveNavMenuRequest extends IRequest {
  RetrieveNavMenuRequest({
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

  final int id;
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
      url: RequestUrl.relativeParts(['menus', id]),
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
