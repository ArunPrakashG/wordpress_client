import '../../wordpress_client.dart';
import '../requests/create/create_tag.dart';
import '../requests/delete/delete_tag.dart';
import '../requests/list/list_tag.dart';
import '../requests/retrive/retrive_tag.dart';
import '../requests/update/update_tag.dart';

class TagInterface extends IInterface
    with
        ICreate<Tag, CreateTagRequest>,
        IDelete<Tag, DeleteTagRequest>,
        IRetrive<Tag, RetriveTagRequest>,
        IUpdate<Tag, UpdateTagRequest>,
        IList<Tag, ListTagRequest> {
  @override
  Future<WordpressResponse<Tag?>> create(
    WordpressRequest<CreateTagRequest> request,
  ) async {
    return internalRequester.createRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> delete(
    WordpressRequest<DeleteTagRequest> request,
  ) async {
    return internalRequester.deleteRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<List<Tag>?>> list(
    WordpressRequest<ListTagRequest> request,
  ) async {
    return internalRequester.listRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> retrive(
    WordpressRequest<RetriveTagRequest> request,
  ) async {
    return internalRequester.retriveRequest<Tag>(request);
  }

  @override
  Future<WordpressResponse<Tag?>> update(
    WordpressRequest<UpdateTagRequest> request,
  ) async {
    return internalRequester.updateRequest<Tag>(request);
  }
}
