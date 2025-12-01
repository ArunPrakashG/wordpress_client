import '../../../wordpress_client.dart';

/// Delete a Navigation (DELETE /wp/v2/navigation/<id>)
final class DeleteNavigationRequest extends IRequest {
  DeleteNavigationRequest({
    required this.id,
    this.force,
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

  final int id;
  final bool? force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{
      if (force != null) 'force': force,
    }
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.delete,
      url: RequestUrl.relative('navigation/$id'),
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
