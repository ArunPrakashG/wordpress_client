import '../../../wordpress_client.dart';

/// Delete a Post (DELETE /wp/v2/posts/<id>).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/posts/#delete-a-post
final class DeletePostRequest extends IRequest {
  DeletePostRequest({
    required this.id,
    this.force,
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

  int id;

  /// Whether to bypass Trash and force deletion.
  bool? force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.delete,
      url: RequestUrl.relativeParts(['posts', id]),
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
