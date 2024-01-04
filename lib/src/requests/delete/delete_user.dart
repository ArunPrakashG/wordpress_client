import '../../../wordpress_client.dart';

final class DeleteUserRequest extends IRequest {
  DeleteUserRequest({
    required this.reassign,
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

  bool? force;
  int reassign;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addIfNotNull('reassign', reassign)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.delete,
      url: RequestUrl.relativeParts(['users', id]),
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
