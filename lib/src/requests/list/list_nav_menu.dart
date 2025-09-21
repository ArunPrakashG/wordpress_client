import '../../../wordpress_client.dart';

/// List Nav_Menus
/// Reference: https://developer.wordpress.org/rest-api/reference/nav_menus/#list-nav_menus
final class ListNavMenuRequest extends IRequest {
  ListNavMenuRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.offset,
    this.order,
    this.orderBy,
    this.hideEmpty,
    this.post,
    this.slug,
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
  List<int>? exclude;
  List<int>? include;
  int? offset;
  Order? order; // asc | desc
  TermOrderBy?
      orderBy; // id, include, name, slug, include_slugs, term_group, description, count
  bool? hideEmpty;
  int? post;
  List<String>? slug;

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
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('hide_empty', hideEmpty)
      ..addIfNotNull('post', post)
      ..addIfNotNull('slug', slug?.join(','))
      ..addAllIfNotNull(this.queryParameters)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('menus'),
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
