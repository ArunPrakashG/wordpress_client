import 'dart:async';

import '../../wordpress_client.dart';
import '../requests/create/create_comment.dart';
import '../requests/delete/delete_comment.dart';
import '../requests/list/list_comment.dart';
import '../requests/retrive/retrive_comment.dart';
import '../requests/update/update_comment.dart';
import '../responses/comment_response.dart';
import '../wordpress_client_base.dart';

class CommentInterface extends IInterface
    with
        ICreate<Comment, CreateCommentRequest>,
        IDelete<Comment, DeleteCommentRequest>,
        IRetrive<Comment, RetriveCommentRequest>,
        IUpdate<Comment, UpdateCommentRequest>,
        IList<Comment, ListCommentRequest> {
  @override
  Future<WordpressResponse<Comment?>> create(
    GenericRequest<CreateCommentRequest> request,
  ) async {
    return internalRequester.createRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> delete(
    GenericRequest<DeleteCommentRequest> request,
  ) async {
    return internalRequester.deleteRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<List<Comment>?>> list(
    GenericRequest<ListCommentRequest> request,
  ) async {
    return internalRequester.listRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> retrive(
    GenericRequest<RetriveCommentRequest> request,
  ) async {
    return internalRequester.retriveRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> update(
    GenericRequest<UpdateCommentRequest> request,
  ) async {
    return internalRequester.updateRequest<Comment>(request);
  }
}
