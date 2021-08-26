import '../builders/request.dart';
import '../responses/response_container.dart';
import '../utilities/serializable_instance.dart';

abstract class ICreateOperation<T, Y> {
  Future<ResponseContainer<T?>> create({required Request<T>? Function(Y) builder, bool shouldWaitWhileClientBusy = false});
}
