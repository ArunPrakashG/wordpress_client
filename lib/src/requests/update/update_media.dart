import '../../../wordpress_client.dart';

/// Update a Media Item (POST /wp/v2/media/<id>).
///
/// Reference: https://developer.wordpress.org/rest-api/reference/media/#update-a-media-item
final class UpdateMediaRequest extends IRequest {
  UpdateMediaRequest({
    required this.id,
    this.date,
    this.dateGmt,
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
    this.meta,
    this.template,
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

  /// The date the media item was published, in the site's timezone.
  DateTime? date;

  /// The date the media item was published, as GMT.
  DateTime? dateGmt;

  /// An alphanumeric identifier for the media item.
  String? slug;

  /// Media item status.
  ContentStatus? status;

  /// Title for the media item.
  String? title;

  /// The ID for the author of the media item.
  int? author;

  /// Comment status for the media item.
  Status? commentStatus;

  /// Ping status for the media item.
  Status? pingStatus;

  /// Alternative text to display when attachment is not displayed.
  String? altText;

  /// Caption for the attachment.
  String? caption;

  /// Description for the attachment.
  String? description;

  /// The ID for the associated post of the attachment.
  int? post;

  /// Meta fields.
  Map<String, dynamic>? meta;

  /// The theme file to use to display the media item.
  String? template;

  /// Unique identifier for the media item.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
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
      ..addIfNotNull('meta', meta)
      ..addIfNotNull('template', template)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
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
