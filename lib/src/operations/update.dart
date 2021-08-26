import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IUpdateOperation<T> {
  Future<ResponseContainer<T?>> update<T extends ISerializable<T>>({T? typeResolver, Request<T>? request, bool shouldWaitWhileClientBusy = false});
}
