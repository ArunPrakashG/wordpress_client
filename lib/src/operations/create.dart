import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin CreateMixin<T, E extends IRequest> {
  InternalRequester get internalRequester;

  Future<WordpressResponse<T?>> create(WordpressRequest<E> request) async {
    return internalRequester.createRequest<T>(request);
  }
}
