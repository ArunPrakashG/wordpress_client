import '../../../wordpress_client.dart';
import '../../utilities/request_url.dart';

final class UpdateTagRequest extends IRequest {
  UpdateTagRequest({
    this.description,
    this.name,
    this.slug,
    required this.id,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
  });

  String? description;
  String? name;
  String? slug;
  int id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('name', name);

    return WordpressRequest(
      body: body,
      method: HttpMethod.post,
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
