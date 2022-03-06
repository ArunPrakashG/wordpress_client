import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';

mixin IUpdate<T, E extends IRequest> {
  Future<WordpressResponse<T?>> update(WordpressRequest<E> request);
}
