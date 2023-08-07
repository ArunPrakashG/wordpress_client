import '../../../wordpress_client.dart';

final class RetrivePostRequest extends IRequest {
  RetrivePostRequest({
    this.context,
    this.password,
    required this.id,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
  });

  RequestContext? context;
  String? password;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('password', password);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['posts', id]),
      queryParameters: queryParameters,
      requireAuth: requireAuth || context == RequestContext.edit,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
