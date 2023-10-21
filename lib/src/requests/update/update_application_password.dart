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
  });

  int userId;
  String uuid;
  String name;
  String appId;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('app_id', appId)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      body: body,
      url: RequestUrl.relativeParts(
        [
          'users',
          userId.toString(),
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
