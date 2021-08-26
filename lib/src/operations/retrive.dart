import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IRetriveOperation<T, Y> {
  Future<ResponseContainer<T?>> retrive({required Request<T>? Function(Y) builder, bool shouldWaitWhileClientBusy = false});
}
