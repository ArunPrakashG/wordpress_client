import '../../../wordpress_client.dart';

final class UpdateMediaRequest extends IRequest {
  UpdateMediaRequest({
    required this.id,
    this.slug,
    this.status,
    this.title,
    this.author,
    this.commentStatus,
    this.pingStatus,
    this.altText,
    this.caption,
    this.description,
    this.post,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  String? slug;
  ContentStatus? status;
  String? title;
  int? author;
  Status? commentStatus;
  Status? pingStatus;
  String? altText;
  String? caption;
  String? description;
  int? post;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('title', title)
      ..addIfNotNull('author', author)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('alt_text', altText)
      ..addIfNotNull('caption', caption)
      ..addIfNotNull('description', description)
      ..addIfNotNull('post', post);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      url: RequestUrl.relativeParts(['media', id]),
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
