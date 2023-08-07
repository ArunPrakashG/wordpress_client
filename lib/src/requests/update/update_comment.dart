import '../../../wordpress_client.dart';

final class UpdateCommentRequest extends IRequest {
  UpdateCommentRequest({
    this.author,
    this.authorIp,
    this.authorUrl,
    this.authorEmail,
    this.authorDisplayName,
    this.authorUserAgent,
    this.parent,
    this.content,
    this.post,
    this.status,
    required this.id,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  int? author;
  String? authorIp;
  String? authorUrl;
  String? authorEmail;
  String? authorDisplayName;
  String? authorUserAgent;
  int? parent;
  String? content;
  int? post;
  CommentStatus? status;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('author', author)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('author_ip', authorIp)
      ..addIfNotNull('author_url', authorUrl)
      ..addIfNotNull('author_email', authorEmail)
      ..addIfNotNull('author_display_name', authorDisplayName)
      ..addIfNotNull('author_user_agent', authorUserAgent)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('content', content)
      ..addIfNotNull('post', post);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
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
