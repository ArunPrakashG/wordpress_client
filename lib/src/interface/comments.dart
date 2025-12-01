import '../../wordpress_client.dart';

/// Comments (wp/v2/comments)
///
/// CRUD operations for WordPress comments via the REST API.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/comments/
///
/// Example:
///
/// ```dart
/// final wp = WordpressClient(baseUrl: 'https://example.com/wp-json');
/// final created = await wp.comments.create(CreateCommentRequest(
///   post: 123,
///   content: 'Great post!',
///   authorEmail: 'john@example.com',
/// ));
///
/// final listed = await wp.comments.list(ListCommentRequest(post: [123]));
/// await wp.comments.update(UpdateCommentRequest(id: created.id, content: 'Updated'));
/// await wp.comments.delete(DeleteCommentRequest(id: created.id, force: true));
/// ```
final class CommentInterface extends IRequestInterface
    with
        CreateOperation<Comment, CreateCommentRequest>,
        DeleteOperation<DeleteCommentRequest>,
        RetrieveOperation<Comment, RetrieveCommentRequest>,
        UpdateOperation<Comment, UpdateCommentRequest>,
        ListOperation<Comment, ListCommentRequest> {}
