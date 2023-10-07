import '../../../wordpress_client.dart';

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
  });

  int id;
  bool? force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
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
