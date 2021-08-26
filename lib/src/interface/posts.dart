part of '../wordpress_client_base.dart';

class PostsInterface implements ICreateOperation<Post>, IDeleteOperation<Post>, IRetriveOperation<Post>, IUpdateOperation<Post>, IListOperation<Post> {
  @override
  Future<ResponseContainer<Post?>> create({Request<Post>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Post>(Post(), request);
  }

  @override
  Future<ResponseContainer<Post?>> delete({Request<Post>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Post>(Post(), request);
  }

  @override
  Future<ResponseContainer<List<Post?>?>> list({Request<List<Post>>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Post>(Post(), request);
  }

  @override
  Future<ResponseContainer<Post?>> retrive({Request<Post>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Post>(Post(), request);
  }

  @override
  Future<ResponseContainer<Post?>> update({Request<Post>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Post>(Post(), request);
  }
}
