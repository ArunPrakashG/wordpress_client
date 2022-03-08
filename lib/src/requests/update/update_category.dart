import '../../../wordpress_client.dart';

class UpdateCategoryRequest implements IRequest {
  UpdateCategoryRequest({
    this.description,
    this.name,
    this.slug,
    this.parent,
    required this.id,
  });

  String? description;
  String? name;
  String? slug;
  int? parent;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent', parent);

    requestContent.endpoint = 'categories/$id';
    requestContent.method = HttpMethod.post;
  }
}
