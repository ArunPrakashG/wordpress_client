import '../requests/request_interface.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin IRetrive<T, E extends IRequest> {
  Future<WordpressResponse<T?>> retrive(GenericRequest<E> request);
}
