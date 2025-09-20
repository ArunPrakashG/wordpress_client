import '../../../wordpress_client.dart';

/// Delete a Nav_Menu
final class DeleteNavMenuRequest extends IRequest {
  DeleteNavMenuRequest({
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

  int id;
  bool? force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final qp = <String, dynamic>{}
      ..addAllIfNotNull(queryParameters)
      ..addIfNotNull('force', force);

    return WordpressRequest(
      headers: headers,
      queryParameters: qp,
      method: HttpMethod.delete,
      url: RequestUrl.relativeParts(['menus', id]),
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
