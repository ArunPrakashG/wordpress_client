import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class CreateCommentRequest extends IRequest {
  CreateCommentRequest({
    this.author,
    this.authorIp,
    this.authorUrl,
    this.authorEmail,
    this.content,
    this.authorDisplayName,
    this.authorUserAgent,
    this.parent,
    this.post,
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
  String? content;
  String? parent;
  String? post;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('author', author)
      ..addIfNotNull('author_ip', authorIp)
      ..addIfNotNull('author_url', authorUrl)
      ..addIfNotNull('author_email', authorEmail)
      ..addIfNotNull('author_display_name', authorDisplayName)
      ..addIfNotNull('author_user_agent', authorUserAgent)
      ..addIfNotNull('content', content)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('post', post);

    return WordpressRequest(
      body: body,
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
