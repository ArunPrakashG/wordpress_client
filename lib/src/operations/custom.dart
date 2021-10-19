import '../builders/request.dart';
import '../responses/response_container.dart';

abstract class ICustomOperation<T> {
  Future<ResponseContainer<T?>> request(Request<T>? request, {bool shouldWaitWhileClientBusy = false});
}
