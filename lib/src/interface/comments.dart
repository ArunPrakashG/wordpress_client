import 'dart:async';

import '../../wordpress_client.dart';
import '../requests/create/create_comment.dart';
import '../requests/delete/delete_comment.dart';
import '../requests/list/list_comment.dart';
import '../requests/retrive/retrive_comment.dart';
import '../requests/update/update_comment.dart';
import '../responses/comment_response.dart';

class CommentInterface extends IInterface
    with
        ICreate<Comment, CreateCommentRequest>,
        IDelete<Comment, DeleteCommentRequest>,
        IRetrive<Comment, RetriveCommentRequest>,
        IUpdate<Comment, UpdateCommentRequest>,
        IList<Comment, ListCommentRequest> {
  @override
  Future<WordpressResponse<Comment?>> create(
    WordpressRequest<CreateCommentRequest> request,
  ) async {
    return internalRequester.createRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> delete(
    WordpressRequest<DeleteCommentRequest> request,
  ) async {
    return internalRequester.deleteRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<List<Comment>?>> list(
    WordpressRequest<ListCommentRequest> request,
  ) async {
    return internalRequester.listRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> retrive(
    WordpressRequest<RetriveCommentRequest> request,
  ) async {
    return internalRequester.retriveRequest<Comment>(request);
  }

  @override
  Future<WordpressResponse<Comment?>> update(
    WordpressRequest<UpdateCommentRequest> request,
  ) async {
    return internalRequester.updateRequest<Comment>(request);
  }
}
