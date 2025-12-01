import '../../../wordpress_client.dart';

/// List Pattern Directory Items (wp/v2/pattern-directory/patterns)
final class ListPatternDirectoryItemsRequest extends IRequest {
  ListPatternDirectoryItemsRequest({
    this.page = 1,
    this.perPage = 100,
    this.search,
    this.category,
    this.keyword,
    this.slug,
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

  int page;
  int perPage;
  String? search;
  int? category; // category ID
  int? keyword; // keyword ID
  String? slug; // pattern slug
  int? offset;
  Order order;
  OrderBy orderBy;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('category', category)
      ..addIfNotNull('keyword', keyword)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('order', order.name)
      ..addIfNotNull('orderby', orderBy.name)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('pattern-directory/patterns'),
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
