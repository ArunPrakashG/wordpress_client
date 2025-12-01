import '../../../wordpress_client.dart';

final class UpdateTagRequest extends IRequest {
  UpdateTagRequest({
    required this.id,
    this.description,
    this.name,
    this.slug,
    this.meta,
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

  /// HTML description of the term.
  String? description;

  /// HTML title for the term.
  String? name;

  /// An alphanumeric identifier for the term.
  String? slug;

  /// Meta fields.
  Map<String, dynamic>? meta;

  /// Unique identifier for the term.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('name', name)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      url: RequestUrl.relativeParts(['tags', id]),
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
