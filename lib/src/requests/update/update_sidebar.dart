import '../../../wordpress_client.dart';

/// Update a Sidebar: POST /wp/v2/sidebars/<id>
final class UpdateSidebarRequest extends IRequest {
  UpdateSidebarRequest({
    required this.id,
    this.widgets,
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

  /// Sidebar ID.
  final String id;
  /// Widget instance IDs in the sidebar.
  final List<String>? widgets;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('widgets', widgets)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relativeParts(['sidebars', id]),
      body: body,
      queryParameters: queryParameters,
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
