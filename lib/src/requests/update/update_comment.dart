import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class UpdateCommentRequest implements IRequest {
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
  Map<String, dynamic> build() {
    return <String, dynamic>{}
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
  }
}
