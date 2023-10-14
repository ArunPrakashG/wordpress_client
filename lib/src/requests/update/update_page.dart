import '../../../wordpress_client.dart';

final class UpdatePageRequest extends IRequest {
  UpdatePageRequest({
    required this.id,
    required this.slug,
    required this.content,
    required this.title,
    this.date,
    this.parent,
    this.dateGmt,
    this.status = ContentStatus.draft,
    this.author,
    this.excerpt,
    this.featuredMedia,
    this.commentStatus = Status.closed,
    this.menuOrder,
    this.pingStatus = Status.closed,
    this.template,
    this.password,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
  });

  int id;
  DateTime? date;
  DateTime? dateGmt;
  String slug;
  ContentStatus status;
  String? password;
  int? parent;
  String title;
  String content;
  int? author;
  String? excerpt;
  int? featuredMedia;
  Status pingStatus;
  Status commentStatus;
  int? menuOrder;
  String? template;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('status', status)
      ..addIfNotNull('password', password)
      ..addIfNotNull('author', author)
      ..addIfNotNull('featured_media', featuredMedia)
      ..addIfNotNull('comment_status', commentStatus.name)
      ..addIfNotNull('ping_status', pingStatus.name)
      ..addIfNotNull('status', status.name)
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('data_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('menu_order', menuOrder)
      ..addIfNotNull('slug', slug)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      url: RequestUrl.relativeParts(['pages', id]),
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
