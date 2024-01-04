import '../../../wordpress_client.dart';

final class ListApplicationPasswordRequest extends IRequest {
  ListApplicationPasswordRequest({
    required this.userId,
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

  int userId;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(
        [
          'users',
          userId.toString(),
          'application-passwords',
        ],
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
