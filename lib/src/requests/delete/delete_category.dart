import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class DeleteCategoryRequest implements IRequest {
  DeleteCategoryRequest({
    this.force,
    required this.id,
  });

  bool? force;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body.addIfNotNull('force', force);

    requestContent.endpoint = 'categories/$id';
    requestContent.method = HttpMethod.delete;
  }
}
