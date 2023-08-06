import '../../../wordpress_client.dart';
import '../../utilities/request_url.dart';

final class DeleteMediaRequest extends IRequest {
  DeleteMediaRequest({
    required this.id,
    this.force,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  int id;
  bool? force;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}..addIfNotNull('force', force);

    return WordpressRequest(
      body: body,
      method: HttpMethod.delete,
      url: RequestUrl.relativeParts(['media', id]),
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
