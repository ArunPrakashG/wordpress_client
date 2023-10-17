import '../../../wordpress_client.dart';

final class ListApplicationPasswordRequest extends IRequest {
  ListApplicationPasswordRequest({
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
  });

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}..addAllIfNotNull(extra);

    return WordpressRequest(
      queryParameters: queryParameters,
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(
        const ['users', 'me', 'application-passwords'],
      ),
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
