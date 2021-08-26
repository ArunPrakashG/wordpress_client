import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class IListOperation<T, Y> {
  Future<ResponseContainer<List<T?>?>> list({required Request<List<T>>? Function(Y) builder, bool shouldWaitWhileClientBusy = false});
}
