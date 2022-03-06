import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class ListCategoryRequest implements IRequest {
  ListCategoryRequest({
    this.context,
    required this.page,
    required this.perPage,
    this.search,
    this.exclude,
    this.include,
    this.orderBy,
    this.order,
    this.slug,
    this.parent,
    this.post,
    this.hideEmpty,
  });

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  List<int>? exclude;
  List<int>? include;
  OrderBy? orderBy;
  String? order;
  List<String>? slug;
  int? parent;
  int? post;
  bool? hideEmpty;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('order_by', orderBy?.name)
      ..addIfNotNull('order', order)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('post', post)
      ..addIfNotNull('hide_empty', hideEmpty);

    requestContent.endpoint = 'categories';
    requestContent.method = HttpMethod.get;
  }
}
