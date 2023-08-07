import '../../../wordpress_client.dart';

final class RetriveMediaRequest extends IRequest {
  RetriveMediaRequest({
    this.context = RequestContext.view,
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
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['media', id]),
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
