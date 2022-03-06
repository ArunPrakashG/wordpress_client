import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

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
