import '../../utilities/helpers.dart';
import '../request_interface.dart';

class CreateCategoryRequest implements IRequest {
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
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent_id', parentId);
  }
}
