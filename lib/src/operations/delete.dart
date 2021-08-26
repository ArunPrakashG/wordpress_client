import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IDeleteOperation<T, Y> {
  Future<ResponseContainer<T?>> delete({required Request<T>? Function(Y) builder, bool shouldWaitWhileClientBusy = false});
}
