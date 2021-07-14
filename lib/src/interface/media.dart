import 'package:wordpress_client/src/crud_operations/create.dart';
import 'package:wordpress_client/src/crud_operations/delete.dart';
import 'package:wordpress_client/src/crud_operations/retrive.dart';
import 'package:wordpress_client/src/crud_operations/update.dart';
import 'package:wordpress_client/src/responses/response_container.dart';
import 'package:wordpress_client/src/requests/request.dart';
import 'package:wordpress_client/src/internal_requester.dart';
import 'package:wordpress_client/src/utilities/serializable_instance.dart';

class MediaInterface<T extends ISerializable<T>> implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T>{

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