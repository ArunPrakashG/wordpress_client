import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class ListMediaRequest implements IRequest {
  ListMediaRequest({
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
    this.parent,
    this.parentExclude,
    this.slug,
    this.mediaType,
    this.mimeType,
    this.status,
  });

  FilterContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  DateTime? after;
  DateTime? before;
  List<int>? exclude;
  List<int>? include;
  FilterCategoryTagSortOrder? orderBy;
  FilterOrder? order;
  List<int>? author;
  List<int>? authorExclude;
  int? offset;
  List<int>? parent;
  List<int>? parentExclude;
  List<String>? slug;
  FilterMediaType? mediaType;
  String? mimeType;
  MediaFilterStatus? status;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('after', after?.toIso8601String())
      ..addIfNotNull('before', before?.toIso8601String())
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
      ..addIfNotNull('status', status?.name);

    requestContent.endpoint = 'media';
    requestContent.method = HttpMethod.get;
  }
}
