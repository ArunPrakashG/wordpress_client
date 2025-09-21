import '../../../wordpress_client.dart';

/// Update an Editor Block
final class UpdateBlockRequest extends IRequest {
  UpdateBlockRequest({
    required this.id,
    this.date,
    this.dateGmt,
    this.slug,
    this.status,
    this.password,
    this.title,
    this.content,
    this.meta,
    this.template,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// ID of the block.
  final int id;

  /// The date the block was published, in the site's timezone.
  DateTime? date;

  /// The date the block was published, as GMT.
  DateTime? dateGmt;

  /// An alphanumeric identifier for the block.
  String? slug;

  /// Block status.
  ContentStatus? status;

  /// A password to protect access to the content.
  String? password;

  /// The title for the block.
  String? title;

  /// The content for the block.
  String? content;

  /// Meta fields for the block.
  Map<String, dynamic>? meta;

  /// The theme file to use to display the block.
  String? template;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('password', password)
      ..addIfNotNull('title', title)
      ..addIfNotNull('content', content)
      ..addIfNotNull('meta', meta)
      ..addIfNotNull('template', template)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('blocks/$id'),
      requireAuth: true,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
