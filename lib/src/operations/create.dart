import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';

mixin ICreate<T, E extends IRequest> {
  Future<WordpressResponse<T?>> create(WordpressRequest<E> request);
}
