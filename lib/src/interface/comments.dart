import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class CommentInterface extends IInterface
    with
        CreateMixin<Comment, CreateCommentRequest>,
        DeleteMixin<DeleteCommentRequest>,
        RetrieveMixin<Comment, RetriveCommentRequest>,
        UpdateMixin<Comment, UpdateCommentRequest>,
        ListMixin<Comment, ListCommentRequest> {}
