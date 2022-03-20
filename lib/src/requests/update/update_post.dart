import '../../../wordpress_client.dart';

class UpdatePostRequest implements IRequest {
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
  void build(RequestContent requestContent) {
    requestContent.body
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

    requestContent.endpoint = 'posts/$id';
    requestContent.method = HttpMethod.post;
  }
}
