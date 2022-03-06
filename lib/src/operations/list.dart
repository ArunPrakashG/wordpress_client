import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';

mixin IList<T, E extends IRequest> {
  Future<WordpressResponse<List<T>?>> list(WordpressRequest<E> request);
}
