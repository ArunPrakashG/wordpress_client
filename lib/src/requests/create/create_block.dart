import '../../../wordpress_client.dart';

/// Create an Editor Block
final class CreateBlockRequest extends IRequest {
  CreateBlockRequest({
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

  /// Publish date in site timezone.
  DateTime? date;

  /// Publish date in GMT.
  DateTime? dateGmt;

  /// Alphanumeric identifier for the block post unique to its type.
  String? slug;

  /// Post status for the block.
  ContentStatus? status;

  /// Password to protect access to the content.
  String? password;

  /// Block title.
  String? title;

  /// Block content (HTML).
  String? content;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  /// Theme template file to use.
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
      url: RequestUrl.relative('blocks'),
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
