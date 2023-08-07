import '../../../wordpress_client.dart';

final class ListPostRequest extends IRequest {
  ListPostRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.after,
    this.before,
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
  DateTime? after;
  DateTime? before;
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
  ContentStatus? status;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('after', after?.toIso8601String())
      ..addIfNotNull('before', before?.toIso8601String())
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
      ..addIfNotNull('status', status?.name);

    return WordpressRequest(
      queryParameters: queryParameters,
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
