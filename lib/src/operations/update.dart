import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class IUpdateOperation<T, Y> {
  Future<ResponseContainer<T?>> update(Request<T>? Function(Y) builder, {bool shouldWaitWhileClientBusy = false});
}
