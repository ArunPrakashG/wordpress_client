import '../../../wordpress_client.dart';
import '../../utilities/helpers.dart';

class DeleteTagRequest implements IRequest {
  DeleteTagRequest({
    this.force,
    required this.id,
  });

  bool? force;
  int id;

  @override
  void build(RequestContent requestContent) {
    requestContent.body.addIfNotNull('force', force);

    requestContent.endpoint = 'tags/$id';
    requestContent.method = HttpMethod.delete;
  }
}
