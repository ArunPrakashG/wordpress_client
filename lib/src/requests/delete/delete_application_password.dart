import 'dart:async';

import '../../../wordpress_client.dart';

final class DeleteApplicationPasswordRequest extends IRequest {
  DeleteApplicationPasswordRequest({
    required this.uuid,
    required this.userId,
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

  @override
  FutureOr<WordpressRequest> build(Uri baseUrl) {
    return WordpressRequest(
      method: HttpMethod.delete,
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
