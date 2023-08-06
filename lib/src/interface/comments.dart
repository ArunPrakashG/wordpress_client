import '../../wordpress_client.dart';

final class CommentInterface extends IRequestInterface
    with
        CreateOperation<Comment, CreateCommentRequest>,
        DeleteOperation<DeleteCommentRequest>,
        RetriveOperation<Comment, RetriveCommentRequest>,
        UpdateOperation<Comment, UpdateCommentRequest>,
        ListOperation<Comment, ListCommentRequest> {}
