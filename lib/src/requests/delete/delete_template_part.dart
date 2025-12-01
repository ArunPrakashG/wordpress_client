import '../../../wordpress_client.dart';

/// Delete a Template Part (DELETE /wp/v2/template-parts/<id>)
final class DeleteTemplatePartRequest extends IRequest {
  DeleteTemplatePartRequest({
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

  final String id;
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
      url: RequestUrl.relative('template-parts/$id'),
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
