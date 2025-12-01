import '../../../wordpress_client.dart';

/// Delete a Template Part Revision (DELETE /wp/v2/template-parts/<parent>/revisions/<id>)
final class DeleteTemplatePartRevisionRequest extends IRequest {
  DeleteTemplatePartRevisionRequest({
    required this.parent,
    required this.id,
    this.force = true,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  final int parent;
  final int id;
  final bool force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{'force': force}
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.delete,
      url: RequestUrl.relative('template-parts/$parent/revisions/$id'),
      queryParameters: query,
      headers: headers,
      requireAuth: true,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
