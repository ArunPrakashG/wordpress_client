import '../../../wordpress_client.dart';

final class CreateCategoryRequest extends IRequest {
  CreateCategoryRequest({
    this.name,
    this.description,
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

  /// HTML title for the term.
  String? name;

  /// HTML description of the term.
  String? description;

  /// An alphanumeric identifier for the term unique to its type.
  String? slug;

  /// The parent term ID.
  int? parent;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('categories'),
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
