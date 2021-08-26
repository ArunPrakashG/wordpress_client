part of '../wordpress_client_base.dart';

class MediaInterface implements ICreateOperation<Media>, IDeleteOperation<Media>, IRetriveOperation<Media>, IUpdateOperation<Media>, IListOperation<Media> {
  @override
  Future<ResponseContainer<Media?>> create({Request<Media>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Media>(Media(), request);
  }

  @override
  Future<ResponseContainer<Media?>> delete({Request<Media>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Media>(Media(), request);
  }

  @override
  Future<ResponseContainer<List<Media?>?>> list({Request<List<Media>>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Media>(Media(), request);
  }

  @override
  Future<ResponseContainer<Media?>> retrive({Request<Media>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Media>(Media(), request);
  }

  @override
  Future<ResponseContainer<Media?>> update({Request<Media>? request, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Media>(Media(), request);
  }
}
