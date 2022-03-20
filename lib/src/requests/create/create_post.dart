import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class CreatePostRequest implements IRequest {
  CreatePostRequest({
    this.slug,
    this.title,
    this.content,
    this.status,
    this.excerpt,
    this.password,
    this.authorId,
    this.featuredMediaId,
    this.commentStatus,
    this.pingStatus,
    this.format,
    this.sticky,
    this.categories,
    this.tags,
  });

  String? slug;
  String? title;
  String? content;
  String? status;
  String? excerpt;
  String? password;
  int? authorId;
  int? featuredMediaId;
  Status? commentStatus;
  Status? pingStatus;
  String? format;
  bool? sticky;
  List<int>? categories;
  List<int>? tags;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('status', status)
      ..addIfNotNull('password', password)
      ..addIfNotNull('author', authorId)
      ..addIfNotNull('featured_media', featuredMediaId)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('format', format)
      ..addIfNotNull('sticky', (sticky ?? false) ? '1' : null)
      ..addIfNotNull('categories', categories?.join(','))
      ..addIfNotNull('tags', tags?.join(','))
      ..addIfNotNull('slug', slug);

    requestContent.endpoint = 'posts';
    requestContent.method = HttpMethod.post;
  }
}
