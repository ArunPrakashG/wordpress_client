import '../../../wordpress_client.dart';

/// List Media (GET /wp/v2/media).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/media/#list-media
final class ListMediaRequest extends IRequest {
  ListMediaRequest({
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
    this.parent,
    this.parentExclude,
    this.slug,
    this.mediaType,
    this.mimeType,
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
  List<int>? exclude;
  List<int>? include;
  OrderBy? orderBy;
  Order? order;
  List<int>? author;
  List<int>? authorExclude;
  int? offset;
  List<int>? parent;
  List<int>? parentExclude;
  List<String>? slug;
  MediaType? mediaType;
  String? mimeType;
  MediaFilterStatus? status;
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
      ..addIfNotNull('exclude', exclude)
      ..addIfNotNull('include', include)
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('author', author?.join(','))
      ..addIfNotNull('author_exclude', authorExclude?.join(','))
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('parent', parent?.join(','))
      ..addIfNotNull('parent_exclude', parentExclude?.join(','))
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('media_type', mediaType?.name)
      ..addIfNotNull('mime_type', mimeType)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('search_columns', searchColumns?.join(','))
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('media'),
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
