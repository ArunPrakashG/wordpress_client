import '../requests/request_interface.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin IUpdate<T, E extends IRequest> {
  Future<WordpressResponse<T?>> update(GenericRequest<E> request);
}
