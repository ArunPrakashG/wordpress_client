import '../../wordpress_client.dart';
import '../requests/create/create_post.dart';
import '../requests/delete/delete_post.dart';
import '../requests/list/list_post.dart';
import '../requests/retrive/retrive_post.dart';
import '../requests/update/update_post.dart';
import '../wordpress_client_base.dart';

class PostsInterface extends IInterface
    with
        ICreate<Post, CreatePostRequest>,
        IDelete<Post, DeletePostRequest>,
        IRetrive<Post, RetrivePostRequest>,
        IUpdate<Post, UpdatePostRequest>,
        IList<Post, ListPostRequest> {
  @override
  Future<WordpressResponse<Post?>> create(
    GenericRequest<CreatePostRequest> request,
  ) async {
    return internalRequester.createRequest<Post>(request);
  }

  @override
  Future<WordpressResponse<Post?>> delete(
    GenericRequest<DeletePostRequest> request,
  ) async {
    return internalRequester.deleteRequest<Post>(request);
  }

  @override
  Future<WordpressResponse<List<Post>?>> list(
    GenericRequest<ListPostRequest> request,
  ) async {
    return internalRequester.listRequest<Post>(request);
  }

  @override
  Future<WordpressResponse<Post?>> retrive(
    GenericRequest<RetrivePostRequest> request,
  ) async {
    return internalRequester.retriveRequest<Post>(request);
  }

  @override
  Future<WordpressResponse<Post?>> update(
    GenericRequest<UpdatePostRequest> request,
  ) async {
    return internalRequester.updateRequest<Post>(request);
  }
}
