import 'dart:async';

import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class CommentInterface extends IInterface
    with
        CreateMixin<Comment, CreateCommentRequest>,
        DeleteMixin<Comment, DeleteCommentRequest>,
        RetriveMixin<Comment, RetriveCommentRequest>,
        UpdateMixin<Comment, UpdateCommentRequest>,
        ListMixin<Comment, ListCommentRequest> {}
