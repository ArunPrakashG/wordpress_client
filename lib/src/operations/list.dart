import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class IListOperation<T, Y> {
  Future<ResponseContainer<List<T>?>> list(
      Request<List<T>>? Function(Y) builder,
      {bool shouldWaitWhileClientBusy = false});
}
