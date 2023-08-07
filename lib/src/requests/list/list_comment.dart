import '../../../wordpress_client.dart';
import '../../utilities/request_url.dart';

final class ListCommentRequest extends IRequest {
  ListCommentRequest({
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
    this.post,
    this.status = CommentStatus.approved,
    this.type = 'comment',
    this.password,
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
  List<int>? parent;
  List<int>? parentExclude;
  List<int>? post;
  CommentStatus? status;
  String? type;
  String? password;

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
      ..addIfNotNull('parent', parent?.join(','))
      ..addIfNotNull('parent_exclude', parentExclude?.join(','))
      ..addIfNotNull('post', post)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('type', type)
      ..addIfNotNull('password', password);

    return WordpressRequest(
      queryParameters: queryParameters,
      method: HttpMethod.get,
      url: RequestUrl.relative('comments'),
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
