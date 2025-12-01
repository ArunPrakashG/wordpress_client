import '../../../wordpress_client.dart';

final class UpdateCategoryRequest extends IRequest {
  UpdateCategoryRequest({
    required this.id,
    this.description,
    this.name,
    this.slug,
    this.parent,
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

  /// The parent term ID.
  int? parent;

  /// Meta fields.
  Map<String, dynamic>? meta;

  /// Unique identifier for the term.
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relativeParts(['categories', id]),
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
