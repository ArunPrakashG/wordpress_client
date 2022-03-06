import '../../wordpress_client.dart';
import '../requests/create/create_tag.dart';
import '../requests/delete/delete_tag.dart';
import '../requests/list/list_tag.dart';
import '../requests/retrive/retrive_tag.dart';
import '../requests/update/update_tag.dart';
import '../wordpress_client_base.dart';

class TagInterface extends IInterface
    with
        ICreate<Tag, CreateTagRequest>,
        IDelete<Tag, DeleteTagRequest>,
        IRetrive<Tag, RetriveTagRequest>,
        IUpdate<Tag, UpdateTagRequest>,
        IList<Tag, ListTagRequest> {
  @override
  Future<WordpressResponse<Tag?>> create(
    GenericRequest<CreateTagRequest> request,
  ) async {
    return internalRequester.createRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> delete(
    GenericRequest<DeleteTagRequest> request,
  ) async {
    return internalRequester.deleteRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<List<Tag>?>> list(
    GenericRequest<ListTagRequest> request,
  ) async {
    return internalRequester.listRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> retrive(
    GenericRequest<RetriveTagRequest> request,
  ) async {
    return internalRequester.retriveRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> update(
    GenericRequest<UpdateTagRequest> request,
  ) async {
    return internalRequester.updateRequest<Tag>(request);
  }
}
