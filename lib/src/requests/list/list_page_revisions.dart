import '../../../wordpress_client.dart';

final class ListPageRevisionsRequest extends IRequest {
  ListPageRevisionsRequest({
    required this.pageId,
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.offset,
    this.order = Order.desc,
    this.orderBy = OrderBy.date,
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

  /// The ID for the parent of the revision (page ID).
  final int pageId;

  /// Scope under which the request is made; determines fields present in response.
  /// One of: view, embed, edit.
  RequestContext? context;

  /// Current page of the collection. Default: 1
  int page;

  /// Maximum number of items to be returned in result set.
  int perPage;

  /// Limit results to those matching a string.
  String? search;

  /// Ensure result set excludes specific IDs.
  List<int>? exclude;

  /// Limit result set to specific IDs.
  List<int>? include;

  /// Offset the result set by a specific number of items.
  int? offset;

  /// Order sort attribute ascending or descending. Default: desc
  Order order;

  /// Sort collection by object attribute. Default: date
  /// One of: date, id, include, relevance, slug, include_slugs, title
  OrderBy orderBy;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('order', order.name)
      ..addIfNotNull('orderby', orderBy.name)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('pages/$pageId/revisions'),
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
