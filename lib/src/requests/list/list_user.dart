import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class ListUserRequest implements IRequest {
  ListUserRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.exclude,
    this.include,
    this.resultOffset,
    this.order,
    this.orderBy,
    this.slug,
    this.roles,
    this.who,
  });

  RequestContext? context;
  int page;
  int perPage;
  String? search;
  List<int>? exclude;
  List<int>? include;
  int? resultOffset;
  Order? order;
  OrderBy? orderBy;
  List<int>? slug;
  int? roles;
  String? who;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('exclude', exclude?.join(','))
      ..addIfNotNull('include', include?.join(','))
      ..addIfNotNull('result_offset', resultOffset)
      ..addIfNotNull('order', order?.name)
      ..addIfNotNull('order_by', orderBy?.name)
      ..addIfNotNull('slug', slug?.join(','))
      ..addIfNotNull('roles', roles)
      ..addIfNotNull('who', who);

    requestContent.endpoint = 'users';
    requestContent.method = HttpMethod.get;
  }
}
