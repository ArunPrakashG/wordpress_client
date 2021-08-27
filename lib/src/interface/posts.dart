import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/post_response.dart';
import '../responses/response_container.dart';
import '../wordpress_client_base.dart';

class PostsInterface extends IInterface
    implements
        ICreateOperation<Post, PostCreateBuilder>,
        IDeleteOperation<Post, PostDeleteBuilder>,
        IRetriveOperation<Post, PostRetriveBuilder>,
        IUpdateOperation<Post, PostUpdateBuilder>,
        IListOperation<Post, PostListBuilder> {
  @override
  Future<ResponseContainer<Post?>> create(Request<Post>? Function(PostCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Post>(
      Post(),
      builder(
        PostCreateBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> delete(Request<Post>? Function(PostDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Post>(
      Post(),
      builder(
        PostDeleteBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Post?>?>> list(Request<List<Post>>? Function(PostListBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Post>(
      Post(),
      builder(
        PostListBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> retrive(Request<Post>? Function(PostRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Post>(
      Post(),
      builder(
        PostRetriveBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> update(Request<Post>? Function(PostUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Post>(
      Post(),
      builder(
        PostUpdateBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }
}
