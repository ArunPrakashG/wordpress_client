import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

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
  void build(RequestContent requestContent) {
    requestContent.body
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
      ..addIfNotNull('slug', slug);

    requestContent.endpoint = 'tags';
    requestContent.method = HttpMethod.post;
  }
}
