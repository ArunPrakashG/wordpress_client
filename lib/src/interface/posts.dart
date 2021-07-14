import '../crud_operations/create.dart';
import '../crud_operations/delete.dart';
import '../crud_operations/retrive.dart';
import '../crud_operations/update.dart';
import '../internal_requester.dart';
import '../requests/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

class PostsInterface<T extends ISerializable<T>> implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T> {
  @override
  Future<ResponseContainer<T>> create<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }

  @override
  Future<ResponseContainer<T>> delete<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }

  @override
  Future<ResponseContainer<List<T>>> list<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<List<T>>(request);
  }

  @override
  Future<ResponseContainer<T>> retriveSingle<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }

  @override
  Future<ResponseContainer<T>> update<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }
}
