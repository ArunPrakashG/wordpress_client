import '../requests/request_interface.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin IList<T, E extends IRequest> {
  Future<WordpressResponse<List<T>?>> list(GenericRequest<E> request);
}
