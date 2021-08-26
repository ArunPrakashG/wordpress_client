part of '../wordpress_client_base.dart';

class UsersInterface implements ICreateOperation<User>, IDeleteOperation<User>, IRetriveOperation<User>, IUpdateOperation<User>, IListOperation<User> {
  @override
  Future<ResponseContainer<User?>> create({Request<User>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<User>(User(), request);
  }

  @override
  Future<ResponseContainer<User?>> delete({Request<User>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<User>(User(), request);
  }

  @override
  Future<ResponseContainer<List<User?>?>> list({Request<List<User>>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<User>(User(), request);
  }

  @override
  Future<ResponseContainer<User?>> retrive({Request<User>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<User>(User(), request);
  }

  @override
  Future<ResponseContainer<User?>> update({Request<User>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<User>(User(), request);
  }
}
