import '../../../wordpress_client.dart';

/// Create a new Page (POST /wp/v2/pages).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/pages/#create-a-page
final class CreatePageRequest extends IRequest {
  CreatePageRequest({
    this.slug,
    this.content,
    this.title,
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
    this.meta,
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

  /// Page publish date in site timezone.
  DateTime? date;

  /// Page publish date in GMT.
  DateTime? dateGmt;

  /// An alphanumeric identifier for the page unique to its type.
  String? slug;

  /// Status of the page.
  ContentStatus status;

  /// A password to protect access to the content and excerpt.
  String? password;

  /// The ID for the parent of the page.
  int? parent;

  /// The title for the page.
  String? title;

  /// The content for the page.
  String? content;

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

  /// The menu order for the page.
  int? menuOrder;

  /// The theme file to use to display the page.
  String? template;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('status', status.name)
      ..addIfNotNull('password', password)
      ..addIfNotNull('author', author)
      ..addIfNotNull('featured_media', featuredMedia)
      ..addIfNotNull('comment_status', commentStatus.name)
      ..addIfNotNull('ping_status', pingStatus.name)
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('menu_order', menuOrder)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('template', template)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('pages'),
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
