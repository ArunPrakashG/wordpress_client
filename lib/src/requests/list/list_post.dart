import '../../../wordpress_client.dart';

/// List Posts (GET /wp/v2/posts).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/posts/#list-posts
final class ListPostRequest extends IRequest {
  ListPostRequest({
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
    this.orderBy,
    this.order,
    this.author,
    this.authorExclude,
    this.offset,
    this.taxRelation,
    this.categories,
    this.categoriesExclude,
    this.tags,
    this.tagsExclude,
    this.sticky,
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

  /// Limit response to posts modified after a given ISO8601 compliant date.
  DateTime? modifiedAfter;
  DateTime? before;

  /// Limit response to posts modified before a given ISO8601 compliant date.
  DateTime? modifiedBefore;
  List<int>? exclude;
  List<int>? include;
  OrderBy? orderBy;
  Order? order;
  List<int>? author;
  List<int>? authorExclude;
  int? offset;
  String? taxRelation;
  List<int>? categories;
  List<int>? categoriesExclude;
  List<int>? tags;
  List<int>? tagsExclude;
  bool? sticky;
  List<String>? slug;
  List<ContentStatus>? status;

  /// Array of column names to be searched.
  List<String>? searchColumns;

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
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('author', author?.join(','))
      ..addIfNotNull('author_exclude', authorExclude?.join(','))
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('tax_relation', taxRelation)
      ..addIfNotNull('categories', categories?.join(','))
      ..addIfNotNull('categories_exclude', categoriesExclude?.join(','))
      ..addIfNotNull('tags', tags?.join(','))
      ..addIfNotNull('tags_exclude', tagsExclude?.join(','))
      ..addIfNotNull('sticky', sticky)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('status', status?.map((e) => e.name).join(','))
      ..addIfNotNull('search_columns', searchColumns?.join(','))
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('posts'),
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
