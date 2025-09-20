import '../../../wordpress_client.dart';

/// List Nav Menu Items (GET /wp/v2/menu-items)
final class ListNavMenuItemRequest extends IRequest {
  ListNavMenuItemRequest({
    this.context,
    this.page = 1,
    this.perPage = 100,
    this.search,
    this.after,
    this.modifiedAfter,
    this.before,
    this.modifiedBefore,
    this.exclude,
    this.include,
    this.offset,
    this.order = Order.asc,
    this.orderBy = OrderBy.menu_order,
    this.searchColumns,
    this.slug,
    this.status,
    this.taxRelation,
    this.menus,
    this.menusExclude,
    this.menuOrder,
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
  int perPage = 100;
  String? search;
  DateTime? after;
  DateTime? modifiedAfter;
  DateTime? before;
  DateTime? modifiedBefore;
  List<int>? exclude;
  List<int>? include;
  int? offset;
  Order order = Order.asc;
  OrderBy orderBy = OrderBy.menu_order;
  List<String>? searchColumns;
  List<String>? slug;
  List<ContentStatus>? status;
  MenuItemsTaxRelation? taxRelation;
  List<int>? menus;
  List<int>? menusExclude;
  int? menuOrder;

  @override
  WordpressRequest build(Uri baseUrl) {
    final qp = <String, dynamic>{}
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
      ..addIfNotNull('tax_relation', taxRelation?.name)
      ..addIfNotNull('menus', menus?.join(','))
      ..addIfNotNull('menus_exclude', menusExclude?.join(','))
      ..addIfNotNull('menu_order', menuOrder)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      queryParameters: qp,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('menu-items'),
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
