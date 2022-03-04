import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class ListTagRequest implements IRequest {
  ListTagRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.orderBy,
    this.order,
    this.offset,
    this.slug,
    this.post,
    this.hideEmpty,
  });

  FilterContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  List<int>? exclude;
  List<int>? include;
  FilterCategoryTagSortOrder? orderBy;
  FilterOrder? order;
  int? offset;
  List<String>? slug;
  int? post;
  bool? hideEmpty;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('post', post)
      ..addIfNotNull('hide_empty', hideEmpty);
  }
}
