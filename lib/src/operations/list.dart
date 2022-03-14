import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin ListMixin<T, E extends IRequest> {
  InternalRequester get internalRequester;

  Future<WordpressResponse<List<T>?>> list(WordpressRequest<E> request) async {
    return internalRequester.listRequest<T>(request);
  }
}
