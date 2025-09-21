import '../../wordpress_client.dart';

/// Interface for interacting with WordPress Posts (wp/v2/posts).
///
/// Supported operations:
/// - List: `GET /wp/v2/posts`
/// - Retrieve: `GET /wp/v2/posts/<id>`
/// - Create: `POST /wp/v2/posts` (requires authorization)
/// - Update: `POST /wp/v2/posts/<id>` (requires authorization)
/// - Delete: `DELETE /wp/v2/posts/<id>` (requires authorization)
///
/// Reference: https://developer.wordpress.org/rest-api/reference/posts/
///
/// Example:
/// ```dart
/// final client = WordpressClient(baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'));
///
/// // List posts
/// final listRes = await client.posts.list(ListPostRequest(perPage: 5));
/// // Retrieve one
/// final one = await client.posts.retrieve(RetrievePostRequest(id: 123));
/// // Create
/// final created = await client.posts.create(CreatePostRequest(title: 'Hello', content: 'World', status: 'publish'));
/// // Update
/// final updated = await client.posts.update(UpdatePostRequest(id: created.data!.id, title: 'Hello again'));
/// // Delete
/// await client.posts.delete(DeletePostRequest(id: created.data!.id, force: true));
/// ```
final class PostsInterface extends IRequestInterface
    with
        CreateOperation<Post, CreatePostRequest>,
        DeleteOperation<DeletePostRequest>,
        RetrieveOperation<Post, RetrievePostRequest>,
        UpdateOperation<Post, UpdatePostRequest>,
        ListOperation<Post, ListPostRequest> {}
