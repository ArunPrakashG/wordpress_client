import '../../../wordpress_client.dart';

final class UpdateApplicationPasswordRequest extends IRequest {
  UpdateApplicationPasswordRequest({
    required this.userId,
    required this.uuid,
    required this.name,
    required this.appId,
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

  /// The user ID the application password belongs to.
  int userId;

  /// Can be generated using the uuid package available on pub.dev.
  String uuid;

  /// A human-friendly name for the application password.
  String name;

  /// Identifier for the client application.
  String appId;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('app_id', appId)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      url: RequestUrl.relativeParts(
        [
          'users',
          userId.toString(),
          'application-passwords',
          uuid,
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
