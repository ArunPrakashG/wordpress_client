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
    super.headers,
    super.queryParameters,
  });

  /// Unique identifier for the page.
  int id;

  /// The date the page was published, in the site's timezone.
  DateTime? date;

  /// The date the page was published, as GMT.
  DateTime? dateGmt;

  /// An alphanumeric identifier for the page.
  String slug;

  /// Page status.
  ContentStatus status;

  /// A password to protect access to the content and excerpt.
  String? password;

  /// ID for the parent page.
  int? parent;

  /// The title for the page.
  String title;

  /// The content for the page.
  String content;

  /// The ID for the author of the page.
  int? author;

  /// Excerpt for the page.
  String? excerpt;

  /// The ID of the featured media for the page.
  int? featuredMedia;

  /// Ping status for the page.
  Status pingStatus;

  /// Comment status for the page.
  Status commentStatus;

  /// The order of the page in relation to other pages.
  int? menuOrder;

  /// The theme file to use to display the page.
  String? template;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('password', password)
      ..addIfNotNull('author', author)
      ..addIfNotNull('featured_media', featuredMedia)
      ..addIfNotNull('comment_status', commentStatus.name)
      ..addIfNotNull('ping_status', pingStatus.name)
      ..addIfNotNull('status', status.name)
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('menu_order', menuOrder)
      ..addIfNotNull('slug', slug)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
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
