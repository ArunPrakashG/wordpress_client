import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class ICreateOperation<T, Y> {
  Future<ResponseContainer<T?>> create(Request<T>? Function(Y) builder, {bool shouldWaitWhileClientBusy = false});
}
