import '../../../wordpress_client.dart';

/// Retrieve a Widget Type: GET /wp/v2/widget-types/<id>
final class RetrieveWidgetTypeRequest extends IRequest {
  RetrieveWidgetTypeRequest({
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
    final query = <String, dynamic>{
      if (context != null) 'context': context!.name,
    }..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['widget-types', id]),
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
