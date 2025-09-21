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
    this.offset,
    this.order,
    this.orderBy,
    this.slug,
    this.roles,
    this.rolesList,
    this.capabilities,
    this.capabilitiesList,
    this.who,
    this.hasPublishedPosts,
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
  List<int>? exclude;
  List<int>? include;

  /// Deprecated: use [offset]. Kept for backward compatibility.
  int? resultOffset;

  /// Offset the result set by a specific number of items.
  int? offset;
  Order? order;
  OrderBy? orderBy;

  /// Limit result set to users with one or more specific slugs.
  List<String>? slug;

  /// CSV roles (legacy)
  int? roles;

  /// Array roles (preferred)
  List<String>? rolesList;

  /// CSV/array capabilities
  String? capabilities;
  List<String>? capabilitiesList;
  String? who;

  /// Limit result set to users who have published posts.
  bool? hasPublishedPosts;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('offset', offset ?? resultOffset)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('roles', rolesList ?? roles)
      ..addIfNotNull('capabilities', capabilitiesList ?? capabilities)
      ..addIfNotNull('who', who)
      ..addIfNotNull('has_published_posts', hasPublishedPosts)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
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
