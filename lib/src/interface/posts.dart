import '../../wordpress_client.dart';
import '../builders_import.dart';

class PostsInterface extends IInterface
    implements
        ICreateOperation<Post, PostCreateBuilder>,
        IDeleteOperation<Post, PostDeleteBuilder>,
        IRetrieveOperation<Post, PostRetriveBuilder>,
        IUpdateOperation<Post, PostUpdateBuilder>,
        IListOperation<Post, PostListBuilder> {
  @override
  Future<ResponseContainer<Post?>> create(
      Request<Post>? Function(PostCreateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .createRequest<Post>(
      Post(),
      builder(
        PostCreateBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> delete(
      Request<Post>? Function(PostDeleteBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .deleteRequest<Post>(
      Post(),
      builder(
        PostDeleteBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Post>?>> list(
      Request<List<Post>>? Function(PostListBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .listRequest<Post>(
      Post(),
      builder(
        PostListBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> retrive(
      Request<Post>? Function(PostRetriveBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .retriveRequest<Post>(
      Post(),
      builder(
        PostRetriveBuilder()
            .withEndpoint('posts')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Post?>> update(
      Request<Post>? Function(PostUpdateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .updateRequest<Post>(
      Post(),
      builder(
        PostUpdateBuilder().withEndpoint('posts').initializeWithDefaultValues(),
      ),
    );
  }
}
