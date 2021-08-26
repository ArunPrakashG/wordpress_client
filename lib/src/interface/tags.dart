part of '../wordpress_client_base.dart';

class TagInterface implements ICreateOperation<Tag>, IDeleteOperation<Tag>, IRetriveOperation<Tag>, IUpdateOperation<Tag>, IListOperation<Tag> {
  @override
  Future<ResponseContainer<Tag?>> create({Request<Tag>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Tag>(Tag(), request);
  }

  @override
  Future<ResponseContainer<Tag?>> delete({Request<Tag>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Tag>(Tag(), request);
  }

  @override
  Future<ResponseContainer<List<Tag?>?>> list({Request<List<Tag>>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Tag>(Tag(), request);
  }

  @override
  Future<ResponseContainer<Tag?>> retrive({Request<Tag>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Tag>(Tag(), request);
  }

  @override
  Future<ResponseContainer<Tag?>> update({Request<Tag>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Tag>(Tag(), request);
  }
}
