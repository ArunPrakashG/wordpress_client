import '../../../wordpress_client.dart';

/// Retrieve one application password: GET `/wp/v2/users/<id>/application-passwords/<uuid>`.
final class RetrieveApplicationPasswordRequest extends IRequest {
  RetrieveApplicationPasswordRequest({
    required this.userId,
    required this.uuid,
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
  String uuid;

  @override
  WordpressRequest build(Uri baseUrl) {
    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(
        [
          'users',
          userId.toString(),
          'application-passwords',
          uuid,
        ],
      ),
      queryParameters: queryParameters,
      headers: headers,
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

/// The old, misspelled name of [RetrieveApplicationPasswordRequest].
@Deprecated(
  'Use RetrieveApplicationPasswordRequest. '
  'RetriveApplicationPasswordRequest will be removed in 11.0.',
)
typedef RetriveApplicationPasswordRequest = RetrieveApplicationPasswordRequest;
