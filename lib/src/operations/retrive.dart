import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class IRetriveOperation<T, Y> {
  Future<ResponseContainer<T?>> retrive(Request<T>? Function(Y) builder, {bool shouldWaitWhileClientBusy = false});
}
