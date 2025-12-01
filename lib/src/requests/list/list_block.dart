import '../../../wordpress_client.dart';

/// List Editor Blocks (wp/v2/blocks)
final class ListBlockRequest extends IRequest {
  ListBlockRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.after,
    this.modifiedAfter,
    this.before,
    this.modifiedBefore,
    this.exclude,
    this.include,
    this.offset,
    this.order = Order.desc,
    this.orderBy = OrderBy.date,
    this.searchColumns,
    this.slug,
    this.status,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  RequestContext? context;
  int page;
  int perPage;
  String? search;
  DateTime? after;
  DateTime? modifiedAfter;
  DateTime? before;
  DateTime? modifiedBefore;
  List<int>? exclude;
  List<int>? include;
  int? offset;
  Order order;
  OrderBy orderBy;
  List<String>? searchColumns;
  List<String>? slug;
  List<ContentStatus>? status;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('after', after?.toIso8601String())
      ..addIfNotNull('modified_after', modifiedAfter?.toIso8601String())
      ..addIfNotNull('before', before?.toIso8601String())
      ..addIfNotNull('modified_before', modifiedBefore?.toIso8601String())
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('order', order.name)
      ..addIfNotNull('orderby', orderBy.name)
      ..addIfNotNull('search_columns', searchColumns?.join(','))
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('status', status?.map((e) => e.name).join(','))
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('blocks'),
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
