import '../../../wordpress_client.dart';

final class DeleteCommentRequest extends IRequest {
  DeleteCommentRequest({
    required this.id,
    this.force,
    this.password,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
  });

  bool? force;
  String? password;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addIfNotNull('password', password)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.delete,
      url: RequestUrl.relativeParts(['comments', id]),
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
