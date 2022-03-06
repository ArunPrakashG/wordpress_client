import '../requests/request_interface.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin ICreate<T, E extends IRequest> {
  Future<WordpressResponse<T?>> create(GenericRequest<E> request);
}
