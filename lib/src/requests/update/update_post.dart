import '../../../wordpress_client.dart';

/// Update an existing Post (POST /wp/v2/posts/<id>).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/posts/#update-a-post
final class UpdatePostRequest extends IRequest {
  UpdatePostRequest({
    required this.id,
    this.date,
    this.dateGmt,
    this.slug,
    this.title,
    this.content,
    this.excerpt,
    this.status,
    this.password,
    this.author,
    this.featuredMedia,
    this.commentStatus,
    this.pingStatus,
    this.format,
    this.sticky,
    this.meta,
    this.template,
    this.categories,
    this.tags,
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

  /// The date the post was published, in the site's timezone.
  DateTime? date;

  /// The date the post was published, as GMT.
  DateTime? dateGmt;

  /// An alphanumeric identifier for the post.
  String? slug;

  /// The title for the post.
  String? title;

  /// The content for the post.
  String? content;

  /// Excerpt for the post.
  String? excerpt;

  /// Post status.
  ContentStatus? status;

  /// A password to protect access to the content and excerpt.
  String? password;

  /// The user ID for the author of the post.
  int? author;

  /// The ID of the featured media for the post.
  int? featuredMedia;

  /// Comment status for the post.
  Status? commentStatus;

  /// Ping status for the post.
  Status? pingStatus;

  /// The format for the post.
  PostFormat? format;

  /// Whether or not the post should be treated as sticky.
  bool? sticky;

  /// Meta fields (arbitrary key/value pairs).
  Map<String, dynamic>? meta;

  /// The theme file to use to display the post.
  String? template;

  /// Category term IDs to assign to the post.
  List<int>? categories;

  /// Tag term IDs to assign to the post.
  List<int>? tags;

  /// Unique identifier for the post.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('password', password)
      ..addIfNotNull('author', author)
      ..addIfNotNull('featured_media', featuredMedia)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('format', format?.name)
      ..addIfNotNull('sticky', sticky)
      ..addIfNotNull('meta', meta)
      ..addIfNotNull('template', template)
      ..addIfNotNull('categories', categories?.join(','))
      ..addIfNotNull('tags', tags?.join(','))
      ..addIfNotNull('slug', slug)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      url: RequestUrl.relativeParts(['posts', id]),
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
