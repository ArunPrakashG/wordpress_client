import '../../../wordpress_client.dart';

/// Delete a Navigation Revision (DELETE /wp/v2/navigation/<parent>/revisions/<id>)
final class DeleteNavigationRevisionRequest extends IRequest {
  DeleteNavigationRevisionRequest({
    required this.parent,
    required this.id,
    required this.force,
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
      url: RequestUrl.relative('navigation/$parent/revisions/$id'),
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
