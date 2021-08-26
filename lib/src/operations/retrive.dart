import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IRetriveOperation<T> {
  Future<ResponseContainer<T?>> retrive<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false});
}
