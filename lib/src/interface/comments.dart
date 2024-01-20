import '../../wordpress_client.dart';

/// Represents the comment interface.
final class CommentInterface extends IRequestInterface
    with
        CreateOperation<Comment, CreateCommentRequest>,
        DeleteOperation<DeleteCommentRequest>,
        RetrieveOperation<Comment, RetrieveCommentRequest>,
        UpdateOperation<Comment, UpdateCommentRequest>,
        ListOperation<Comment, ListCommentRequest> {}
