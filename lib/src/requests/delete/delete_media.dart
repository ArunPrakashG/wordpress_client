import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class DeleteMediaRequest implements IRequest {
  DeleteMediaRequest({
    required this.id,
    this.force,
  });

  int id;
  bool? force;

  @override
  void build(RequestContent requestContent) {
    requestContent.body.addIfNotNull('force', force);

    requestContent.endpoint = 'media/$id';
    requestContent.method = HttpMethod.delete;
  }
}
