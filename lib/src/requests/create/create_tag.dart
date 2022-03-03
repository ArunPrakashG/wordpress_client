import '../../utilities/helpers.dart';
import '../request_interface.dart';

class CreateTagRequest implements IRequest {
  CreateTagRequest({
    this.description,
    required this.name,
    required this.slug,
  });

  String? description;
  String name;
  String slug;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug);
  }
}
