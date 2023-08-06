import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class ListCategoryRequest extends IRequest {
  ListCategoryRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.orderBy,
    this.order,
    this.slug,
    this.parent,
    this.post,
    this.hideEmpty,
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
  List<int>? exclude;
  List<int>? include;
  OrderBy? orderBy;
  Order? order;
  List<String>? slug;
  int? parent;
  int? post;
  bool? hideEmpty;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, String>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('order_by', orderBy?.name)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('post', post)
      ..addIfNotNull('hide_empty', hideEmpty);

    return WordpressRequest(
      queryParams: queryParameters,
      method: HttpMethod.get,
      url: RequestUrl.relative('categories'),
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
