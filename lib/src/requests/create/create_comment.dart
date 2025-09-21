import '../../../wordpress_client.dart';

final class CreateCommentRequest extends IRequest {
  CreateCommentRequest({
    this.author,
    this.authorIp,
    this.authorUrl,
    this.authorEmail,
    this.authorName,
    this.content,
    this.authorDisplayName,
    this.authorUserAgent,
    this.parent,
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

  /// User ID for the comment author.
  int? author;

  /// IP address for the comment author.
  String? authorIp;

  /// URL for the comment author.
  String? authorUrl;

  /// Email address for the comment author.
  String? authorEmail;

  /// Display name for the comment author.
  String? authorName;

  /// Display name (alternative) for the comment author.
  String? authorDisplayName;

  /// User agent for the comment author.
  String? authorUserAgent;

  /// Content of the comment.
  String? content;

  /// The ID for the parent of the comment.
  int? parent;

  /// The post ID the comment belongs to.
  int? post;

  /// Comment status.
  CommentStatus? status;

  /// The date the comment was published, in the site timezone.
  DateTime? date;

  /// The date the comment was published, as GMT.
  DateTime? dateGmt;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('author', author)
      ..addIfNotNull('author_ip', authorIp)
      ..addIfNotNull('author_url', authorUrl)
      ..addIfNotNull('author_email', authorEmail)
      ..addIfNotNull('author_name', authorName)
      ..addIfNotNull('author_display_name', authorDisplayName)
      ..addIfNotNull('author_user_agent', authorUserAgent)
      ..addIfNotNull('content', content)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('post', post)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('comments'),
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
