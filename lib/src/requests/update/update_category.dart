import '../../utilities/helpers.dart';
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
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('id', id);
  }
}
