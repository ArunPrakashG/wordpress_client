import '../../../wordpress_client.dart';

/// Delete a Widget: DELETE /wp/v2/widgets/<id>
final class DeleteWidgetRequest extends IRequest {
  DeleteWidgetRequest({
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
  final bool? force; // Whether to force removal or move to inactive

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.delete,
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
