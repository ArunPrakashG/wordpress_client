import '../../../wordpress_client.dart';

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

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  List<int>? exclude;
  List<int>? include;
  OrderBy? orderBy;
  Order? order;
  int? offset;
  List<String>? slug;
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
      ..addIfNotNull('orderby', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('offset', offset)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('post', post)
      ..addIfNotNull('hide_empty', hideEmpty);

    requestContent.endpoint = 'tags';
    requestContent.method = HttpMethod.get;
  }
}
