import '../../../wordpress_client.dart';
import '../../utilities/request_url.dart';

final class UpdatePostRequest extends IRequest {
  UpdatePostRequest({
    this.slug,
    this.title,
    this.content,
    this.excerpt,
    this.status,
    this.author,
    this.featuredMedia,
    this.commentStatus,
    this.pingStatus,
    this.format,
    this.sticky,
    this.categories,
    this.tags,
    required this.id,
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
  String? excerpt;
  ContentStatus? status;
  int? author;
  int? featuredMedia;
  Status? commentStatus;
  Status? pingStatus;
  PostFormat? format;
  bool? sticky;
  List<int>? categories;
  List<int>? tags;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('excerpt', excerpt)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('author', author)
      ..addIfNotNull('featured_media', featuredMedia)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('format', format?.name)
      ..addIfNotNull('sticky', (sticky ?? false) ? '1' : null)
      ..addIfNotNull('categories', categories?.join(','))
      ..addIfNotNull('tags', tags?.join(','))
      ..addIfNotNull('slug', slug);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
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
