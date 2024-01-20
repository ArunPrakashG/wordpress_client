import '../../wordpress_client.dart';

/// Represents the post interface.
final class PostsInterface extends IRequestInterface
    with
        CreateOperation<Post, CreatePostRequest>,
        DeleteOperation<DeletePostRequest>,
        RetrieveOperation<Post, RetrievePostRequest>,
        UpdateOperation<Post, UpdatePostRequest>,
        ListOperation<Post, ListPostRequest> {}
