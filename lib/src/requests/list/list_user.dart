import '../../../wordpress_client.dart';

final class ListUserRequest extends IRequest {
  ListUserRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.resultOffset,
    this.order,
    this.orderBy,
    this.slug,
    this.roles,
    this.who,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
  });

  RequestContext? context;
  int page;
  int perPage;
  String? search;
  List<int>? exclude;
  List<int>? include;
  int? resultOffset;
  Order? order;
  OrderBy? orderBy;
  List<int>? slug;
  int? roles;
  String? who;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('result_offset', resultOffset)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('order_by', orderBy?.name)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('roles', roles)
      ..addIfNotNull('who', who);

    return WordpressRequest(
      queryParameters: queryParameters,
      method: HttpMethod.get,
      url: RequestUrl.relative('users'),
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
