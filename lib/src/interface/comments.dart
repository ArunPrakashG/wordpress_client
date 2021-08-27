import 'dart:async';

import '../../wordpress_client.dart';
import '../builders/create/comment_create.dart';
import '../builders/delete/comment_delete.dart';
import '../builders/list/comment_list.dart';
import '../builders/request.dart';
import '../builders/retrive/comment_retrive.dart';
import '../builders/update/comment_update.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/comment_response.dart';
import '../responses/response_container.dart';
import 'interface_base.dart';

class CommentInterface extends IInterface
    implements
        ICreateOperation<Comment, CommentCreateBuilder>,
        IDeleteOperation<Comment, CommentDeleteBuilder>,
        IRetriveOperation<Comment, CommentRetriveBuilder>,
        IUpdateOperation<Comment, CommentUpdateBuilder>,
        IListOperation<Comment, CommentListBuilder> {
  @override
  Future<ResponseContainer<Comment?>> create(Request<Comment>? Function(CommentCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).createRequest<Comment>(
      Comment(),
      builder(
        CommentCreateBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> delete(Request<Comment>? Function(CommentDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).deleteRequest<Comment>(
      Comment(),
      builder(
        CommentDeleteBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Comment?>?>> list(Request<List<Comment>>? Function(CommentListBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).listRequest<Comment>(
      Comment(),
      builder(
        CommentListBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> retrive(Request<Comment>? Function(CommentRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).retriveRequest<Comment>(
      Comment(),
      builder(
        CommentRetriveBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> update(Request<Comment>? Function(CommentUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).updateRequest<Comment>(
      Comment(),
      builder(
        CommentUpdateBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }
}
