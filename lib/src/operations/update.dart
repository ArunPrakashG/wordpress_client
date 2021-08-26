import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IUpdateOperation<T, Y> {
  Future<ResponseContainer<T?>> update({required Request<T>? Function(Y) builder, bool shouldWaitWhileClientBusy = false});
}
