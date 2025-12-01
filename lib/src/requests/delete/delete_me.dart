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
    final query = <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addIfNotNull('reassign', reassign)
      ..addAllIfNotNull(queryParameters)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      headers: headers,
      queryParameters: query,
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
