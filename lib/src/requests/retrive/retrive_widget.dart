import '../../../wordpress_client.dart';

/// Retrieve a Widget: GET /wp/v2/widgets/<id>
final class RetrieveWidgetRequest extends IRequest {
  RetrieveWidgetRequest({
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

  final String id;
  final RequestContext? context;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['widgets', id]),
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
