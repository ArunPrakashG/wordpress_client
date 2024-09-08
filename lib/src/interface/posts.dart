import '../../wordpress_client.dart';

/// Represents the interface for interacting with WordPress posts.
///
/// This class provides methods for creating, retrieving, updating, deleting,
/// and listing posts in a WordPress site.
///
/// Example usage:
///
/// ```dart
/// final wordpress = WordpressClient(baseUrl: 'https://your-wordpress-site.com');
/// final postsInterface = wordpress.posts;
///
/// // Create a new post
/// final newPost = await postsInterface.create(CreatePostRequest(
///   title: 'My New Post',
///   content: 'This is the content of my new post.',
///   status: 'publish',
/// ));
///
/// // Retrieve a post
/// final post = await postsInterface.retrieve(RetrievePostRequest(id: 123));
///
/// // Update a post
/// final updatedPost = await postsInterface.update(UpdatePostRequest(
///   id: 123,
///   title: 'Updated Post Title',
/// ));
///
/// // Delete a post
/// await postsInterface.delete(DeletePostRequest(id: 123));
///
/// // List posts
/// final posts = await postsInterface.list(ListPostRequest(
///   perPage: 10,
///   page: 1,
/// ));
/// ```
final class PostsInterface extends IRequestInterface
    with
        CreateOperation<Post, CreatePostRequest>,
        DeleteOperation<DeletePostRequest>,
        RetrieveOperation<Post, RetrievePostRequest>,
        UpdateOperation<Post, UpdatePostRequest>,
        ListOperation<Post, ListPostRequest> {}
