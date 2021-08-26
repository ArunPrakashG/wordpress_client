part of '../wordpress_client_base.dart';

class CategoryInterface<T extends ISerializable<T>>
    implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T>, IListOperation<T> {
  @override
  Future<ResponseContainer<T?>> create<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T?>> delete<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<List<T?>?>> list<T extends ISerializable<T>>(
      {T? typeResolver, Request<List<T>>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<T?>(typeResolver, request);
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
