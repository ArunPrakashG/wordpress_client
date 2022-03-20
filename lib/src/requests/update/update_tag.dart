import '../../../wordpress_client.dart';

class UpdateTagRequest implements IRequest {
  UpdateTagRequest({
    this.description,
    this.name,
    this.slug,
    required this.id,
  });

  String? description;
  String? name;
  String? slug;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('name', name);

    requestContent.endpoint = 'tags/$id';
    requestContent.method = HttpMethod.post;
  }
}
