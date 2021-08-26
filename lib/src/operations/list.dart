import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IListOperation<T> {
  Future<ResponseContainer<List<T?>?>> list<T extends ISerializable<T>>({T? typeResolver, Request<List<T>>? request, bool shouldWaitWhileClientBusy = false});
}
