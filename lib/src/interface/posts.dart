import 'package:wordpress_client/src/crud_operations/create.dart';
import 'package:wordpress_client/src/crud_operations/delete.dart';
import 'package:wordpress_client/src/crud_operations/retrive.dart';
import 'package:wordpress_client/src/crud_operations/update.dart';
import 'package:wordpress_client/src/requests/request.dart';
import 'package:wordpress_client/src/internal_requester.dart';
import 'package:wordpress_client/src/responses/post_response.dart';
import 'package:wordpress_client/src/responses/response_container.dart';

class PostsInterface<T> implements ICreateOperation<T>, IDeleteOperation<T>, IRetriveOperation<T>, IUpdateOperation<T> {
  PostsInterface();

  @override
  Future<ResponseContainer<T>> create<T>({Request request, InternalRequester requesterClient}) {    
    return requesterClient.requestAsync<T>(request);
  }

  @override
  Future<ResponseContainer<T>> delete<T>({Request request, InternalRequester requesterClient}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<ResponseContainer<List<T>>> retriveList<T>({Request request, InternalRequester requesterClient}) {}

  @override
  Future<ResponseContainer<T>> retriveSingle<T>({Request request, InternalRequester requesterClient}) {
    // TODO: implement retriveSingle
    throw UnimplementedError();
  }

  @override
  Future<ResponseContainer<T>> update<T>({Request request, InternalRequester requesterClient}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
