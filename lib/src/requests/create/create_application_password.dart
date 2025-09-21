import '../../../wordpress_client.dart';

/// Create an Application Password for a user (POST /wp/v2/users/<id>/application-passwords).
final class CreateApplicationPasswordRequest extends IRequest {
  CreateApplicationPasswordRequest({
    required this.name,
    required this.userId,
    this.appId,
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

  /// Optional application identifier to associate with the password.
  String? appId;

  /// A human‑readable name for this application password.
  String name;

  /// Target user ID for whom the application password will be created.
  int userId;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('app_id', appId)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
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
