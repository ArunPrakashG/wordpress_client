import '../../../wordpress_client.dart';

final class DeleteMeRequest extends IRequest {
  DeleteMeRequest({
    required this.reassign,
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
      url: RequestUrl.relativeParts(const ['users', 'me']),
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
