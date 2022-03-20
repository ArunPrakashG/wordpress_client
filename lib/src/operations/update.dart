import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin UpdateMixin<T, E extends IRequest> {
  InternalRequester get internalRequester;

  Future<WordpressResponse<T?>> update(WordpressRequest<E> request) async {
    return internalRequester.updateRequest<T>(request);
  }
}
