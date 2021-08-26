part of '../wordpress_client_base.dart';

class CommentInterface
    implements
        ICreateOperation<Comment, CommentCreateBuilder>,
        IDeleteOperation<Comment, CommentDeleteBuilder>,
        IRetriveOperation<Comment, CommentRetriveBuilder>,
        IUpdateOperation<Comment, CommentUpdateBuilder>,
        IListOperation<Comment, CommentListBuilder> {
  @override
  Future<ResponseContainer<Comment?>> create(
      {required Request<Comment>? Function(CommentCreateBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Comment>(
      Comment(),
      builder(
        CommentCreateBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> delete(
      {required Request<Comment>? Function(CommentDeleteBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Comment>(
      Comment(),
      builder(
        CommentDeleteBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Comment?>?>> list(
      {required Request<List<Comment>>? Function(CommentListBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Comment>(
      Comment(),
      builder(
        CommentListBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> retrive(
      {required Request<Comment>? Function(CommentRetriveBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Comment>(
      Comment(),
      builder(
        CommentRetriveBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Comment?>> update(
      {required Request<Comment>? Function(CommentUpdateBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Comment>(
      Comment(),
      builder(
        CommentUpdateBuilder().withEndpoint('comments').initializeWithDefaultValues(),
      ),
    );
  }
}
