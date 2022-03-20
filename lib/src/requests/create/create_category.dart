import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class CreateCategoryRequest extends IRequest {
  CreateCategoryRequest({
    this.name,
    this.description,
    this.slug,
    this.parentId,
  });

  String? name;
  String? description;
  String? slug;
  int? parentId;

  @override
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('name', name)
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent_id', parentId);

    requestContent.endpoint = 'categories';
    requestContent.method = HttpMethod.post;
  }
}
