import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

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
