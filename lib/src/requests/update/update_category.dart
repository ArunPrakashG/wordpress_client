import '../../../wordpress_client.dart';

final class UpdateCategoryRequest extends IRequest {
  UpdateCategoryRequest({
    required this.id,
    this.description,
    this.name,
    this.slug,
    this.parent,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
  });

  String? description;
  String? name;
  String? slug;
  int? parent;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent', parent)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
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
