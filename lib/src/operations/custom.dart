import '../requests/request_interface.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin ICustomOperation<T, E extends IRequest> {
  Future<WordpressResponse<T?>> request(GenericRequest<E> request);
}
