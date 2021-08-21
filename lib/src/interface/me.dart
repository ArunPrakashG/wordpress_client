import '../builders/request.dart';
import '../internal_requester.dart';
import '../operations/delete.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

class MeInterface<T extends ISerializable<T>>
    implements IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T> {
  @override
  Future<ResponseContainer<T?>> delete<T extends ISerializable<T>>(
      {T? typeResolver,
      Request<T>? request,
      InternalRequester? requesterClient}) {
    return requesterClient!.deleteRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T?>> retrive<T extends ISerializable<T>>(
      {T? typeResolver,
      Request<T>? request,
      InternalRequester? requesterClient}) {
    return requesterClient!.retriveRequest<T?>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T?>> update<T extends ISerializable<T>>(
      {T? typeResolver,
      Request<T>? request,
      InternalRequester? requesterClient}) {
    return requesterClient!.updateRequest<T?>(typeResolver, request);
  }
}
