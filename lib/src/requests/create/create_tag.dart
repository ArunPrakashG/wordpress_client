import '../../../wordpress_client.dart';

final class CreateTagRequest extends IRequest {
  CreateTagRequest({
    required this.name,
    required this.slug,
    this.description,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  String? description;
  String name;
  String slug;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
      url: RequestUrl.relative('tags'),
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
