import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';

mixin IDelete<T, E extends IRequest> {
  Future<WordpressResponse<T?>> delete(WordpressRequest<E> request);
}
