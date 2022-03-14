import '../requests/request_interface.dart';
import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';
import '../wordpress_client_base.dart';

mixin RetriveMixin<T, E extends IRequest> {
  InternalRequester get internalRequester;

  Future<WordpressResponse<T?>> retrive(WordpressRequest<E> request) async {
    return internalRequester.retriveRequest<T>(request);
  }
}
