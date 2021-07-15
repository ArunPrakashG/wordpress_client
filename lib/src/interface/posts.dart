import 'package:wordpress_client/src/operations/list.dart';

import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../internal_requester.dart';
import '../requests/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

class PostsInterface<T extends ISerializable<T>>
    implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T>, IListOperation<T> {
  @override
  Future<ResponseContainer<T>> create<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.createRequest<T>(request);
  }

  @override
  Future<ResponseContainer<T>> delete<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.deleteRequest<T>(request);
  }

  @override
  Future<ResponseContainer<List<T>>> list<T extends ISerializable<T>>({T resolver, Request request, InternalRequester requesterClient}) {
    return requesterClient.listRequest<T>(resolver, request);
  }

  @override
  Future<ResponseContainer<T>> retrive<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }

  @override
  Future<ResponseContainer<T>> update<T>({Request request, InternalRequester requesterClient}) {
    return requesterClient.requestAsync<T>(request);
  }
}
