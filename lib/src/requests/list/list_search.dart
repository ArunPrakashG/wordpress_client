import '../../../wordpress_client.dart';

final class ListSearchRequest extends IRequest {
  ListSearchRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.type,
    this.subType,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
  });

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  SearchType? type;
  String? subType;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('type', type?.name)
      ..addIfNotNull('subtype', subType);

    return WordpressRequest(
      queryParameters: queryParameters,
      method: HttpMethod.get,
      url: RequestUrl.relative('search'),
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
