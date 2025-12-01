import '../../../wordpress_client.dart';

/// List Pages (GET /wp/v2/pages).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/pages/#list-pages
final class ListPageRequest extends IRequest {
  ListPageRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.after,
    this.modifiedAfter,
    this.before,
    this.modifiedBefore,
    this.author,
    this.authorExclude,
    this.exclude,
    this.include,
    this.offset,
    this.order,
    this.orderBy,
    this.menuOrder,
    this.parent,
    this.parentExclude,
    this.slug,
    this.status,
    this.searchColumns,
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
  int page = 1;
  int perPage = 10;
  String? search;
  DateTime? after;
  DateTime? modifiedAfter;
  DateTime? before;
  DateTime? modifiedBefore;
  List<int>? author;
  List<int>? authorExclude;
  List<int>? exclude;
  List<int>? include;
  int? offset;
  Order? order;
  OrderBy? orderBy;
  int? menuOrder;
  List<int>? parent;
  List<int>? parentExclude;
  List<String>? slug;
  List<ContentStatus>? status;
  List<String>? searchColumns;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('after', after?.toIso8601String())
      ..addIfNotNull('before', before?.toIso8601String())
      ..addIfNotNull('modified_before', modifiedBefore?.toIso8601String())
      ..addIfNotNull('modified_after', modifiedAfter?.toIso8601String())
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('menu_order', menuOrder)
      ..addIfNotNull('author', author?.join(','))
      ..addIfNotNull('author_exclude', authorExclude?.join(','))
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('parent', parent?.join(','))
      ..addIfNotNull('parent_exclude', parentExclude?.join(','))
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('status', status?.map((e) => e.name).join(','))
      ..addIfNotNull('search_columns', searchColumns?.join(','))
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('pages'),
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
