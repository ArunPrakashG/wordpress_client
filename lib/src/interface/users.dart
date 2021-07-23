import '../internal_requester.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

class UsersInterface<T extends ISerializable<T>>
    implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T>, IListOperation<T> {
  @override
  Future<ResponseContainer<T>> create<T extends ISerializable<T>>({T typeResolver, Request<T> request, InternalRequester requesterClient}) {
    return requesterClient.createRequest<T>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T>> delete<T extends ISerializable<T>>({T typeResolver, Request<T> request, InternalRequester requesterClient}) {
    return requesterClient.deleteRequest<T>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<List<T>>> list<T extends ISerializable<T>>({T typeResolver, Request<List<T>> request, InternalRequester requesterClient}) {
    return requesterClient.listRequest<T>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T>> retrive<T extends ISerializable<T>>({T typeResolver, Request<T> request, InternalRequester requesterClient}) {
    return requesterClient.retriveRequest<T>(typeResolver, request);
  }

  @override
  Future<ResponseContainer<T>> update<T extends ISerializable<T>>({T typeResolver, Request<T> request, InternalRequester requesterClient}) {
    return requesterClient.updateRequest<T>(typeResolver, request);
  }
}
