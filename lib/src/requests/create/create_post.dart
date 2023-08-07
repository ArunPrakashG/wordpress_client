import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class CreatePostRequest extends IRequest {
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
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
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
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
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

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      url: RequestUrl.relative('posts'),
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
