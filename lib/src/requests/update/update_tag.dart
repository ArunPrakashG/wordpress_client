import '../../utilities/helpers.dart';
import '../request_interface.dart';

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
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('name', name);
  }
}
