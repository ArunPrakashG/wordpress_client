import '../../../wordpress_client.dart';

/// List Widgets: GET /wp/v2/widgets
final class ListWidgetsRequest extends IRequest {
  ListWidgetsRequest({
    this.context,
    this.sidebar,
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

  final RequestContext? context;
  final String? sidebar;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('sidebar', sidebar)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('widgets'),
      queryParameters: query,
      headers: headers,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      requireAuth: requireAuth,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
