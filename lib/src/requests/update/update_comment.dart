import '../../../wordpress_client.dart';

final class UpdateCommentRequest extends IRequest {
  UpdateCommentRequest({
    required this.id,
    this.author,
    this.authorIp,
    this.authorUrl,
    this.authorEmail,
    this.authorName,
    this.authorDisplayName,
    this.authorUserAgent,
    this.parent,
    this.content,
    this.post,
    this.status,
    this.date,
    this.dateGmt,
    this.meta,
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

  /// The ID of the user object, if author was a user.
  int? author;

  /// IP address for the author of the comment.
  String? authorIp;

  /// URL for the author of the comment.
  String? authorUrl;

  /// Email address for the author of the comment.
  String? authorEmail;

  /// Display name for the comment author.
  String? authorName;

  /// Display name for the comment author (alias field).
  String? authorDisplayName;

  /// User agent for the author of the comment.
  String? authorUserAgent;

  /// The ID for the parent of the comment.
  int? parent;

  /// The content for the comment.
  String? content;

  /// The ID of the associated post object.
  int? post;

  /// State of the comment.
  CommentStatus? status;

  /// The date the comment was published, in the site's timezone.
  DateTime? date;

  /// The date the comment was published, as GMT.
  DateTime? dateGmt;

  /// Meta fields.
  Map<String, dynamic>? meta;

  /// Unique identifier for the comment.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('author', author)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('author_ip', authorIp)
      ..addIfNotNull('author_url', authorUrl)
      ..addIfNotNull('author_email', authorEmail)
      ..addIfNotNull('author_name', authorName)
      ..addIfNotNull('author_display_name', authorDisplayName)
      ..addIfNotNull('author_user_agent', authorUserAgent)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('content', content)
      ..addIfNotNull('post', post)
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      url: RequestUrl.relativeParts(['comments', id]),
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
