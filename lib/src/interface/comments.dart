import '../../wordpress_client.dart';

/// Represents the comment interface for interacting with WordPress comments.
///
/// This interface provides methods for creating, deleting, retrieving, updating,
/// and listing comments in a WordPress site.
///
/// Example usage:
///
/// ```dart
/// final wp = WordpressClient(baseUrl: 'https://your-wordpress-site.com/wp-json');
/// final commentInterface = wp.comments;
///
/// // Create a new comment
/// final newComment = await commentInterface.create(CreateCommentRequest(
///   content: 'Great post!',
///   post: 123,
///   author: 'John Doe',
///   authorEmail: 'john@example.com',
/// ));
///
/// // Retrieve a comment
/// final comment = await commentInterface.retrieve(RetrieveCommentRequest(id: 456));
///
/// // Update a comment
/// final updatedComment = await commentInterface.update(UpdateCommentRequest(
///   id: 456,
///   content: 'Updated comment content',
/// ));
///
/// // Delete a comment
/// await commentInterface.delete(DeleteCommentRequest(id: 456));
///
/// // List comments
/// final comments = await commentInterface.list(ListCommentRequest(
///   post: 123,
///   status: 'approved',
/// ));
/// ```
final class CommentInterface extends IRequestInterface
    with
        CreateOperation<Comment, CreateCommentRequest>,
        DeleteOperation<DeleteCommentRequest>,
        RetrieveOperation<Comment, RetrieveCommentRequest>,
        UpdateOperation<Comment, UpdateCommentRequest>,
        ListOperation<Comment, ListCommentRequest> {}
