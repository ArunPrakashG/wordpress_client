import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class IDeleteOperation<T, Y> {
  Future<ResponseContainer<T?>> delete(Request<T>? Function(Y) builder, {bool shouldWaitWhileClientBusy = false});
}
