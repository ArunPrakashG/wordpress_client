import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class DeletePostRequest implements IRequest {
  DeletePostRequest({
    required this.id,
    this.force,
  });

  int id;
  bool? force;

  @override
  void build(RequestContent requestContent) {
    requestContent.body.addIfNotNull('force', force);

    requestContent.endpoint = 'posts/$id';
    requestContent.method = HttpMethod.delete;
  }
}
