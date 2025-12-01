import '../../../wordpress_client.dart';

/// Retrieve a Template Revision (GET /wp/v2/templates/<parent>/revisions/<id>)
final class RetrieveTemplateRevisionRequest extends IRequest {
  RetrieveTemplateRevisionRequest({
    required this.parent,
    required this.id,
    this.context,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  final int parent;
  final int id;
  final RequestContext? context;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{
      if (context != null) 'context': context!.name,
    }
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('templates/$parent/revisions/$id'),
      queryParameters: query,
      headers: headers,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
