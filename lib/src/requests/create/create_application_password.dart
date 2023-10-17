import '../../../wordpress_client.dart';

final class CreateApplicationPasswordRequest extends IRequest {
  CreateApplicationPasswordRequest({
    required this.name,
    this.appName,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
  });

  String? appName;
  String name;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relativeParts(
        const [
          'users',
          'me',
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
