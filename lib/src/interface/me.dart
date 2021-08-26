part of '../wordpress_client_base.dart';

class MeInterface implements IDeleteOperation<User>, IRetriveOperation<User>, IUpdateOperation<User> {
  @override
  Future<ResponseContainer<T?>> delete<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T?>> retrive<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T?>> update<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<T?>(typeResolver, request);
  }
}
