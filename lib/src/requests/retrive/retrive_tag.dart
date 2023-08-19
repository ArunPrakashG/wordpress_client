import '../../../wordpress_client.dart';

final class RetriveTagRequest extends IRequest {
  RetriveTagRequest({
    required this.id,
    this.context,
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
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relativeParts(['tags', id]),
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
