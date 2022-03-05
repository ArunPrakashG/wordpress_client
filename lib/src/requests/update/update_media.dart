import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class UpdateMediaRequest implements IRequest {
  UpdateMediaRequest({
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
    required this.id,
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
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('title', title)
      ..addIfNotNull('author', author)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('alt_text', altText)
      ..addIfNotNull('caption', caption)
      ..addIfNotNull('description', description)
      ..addIfNotNull('post', post)
      ..addIfNotNull('id', id);
  }
}
