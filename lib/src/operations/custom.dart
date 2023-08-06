import '../library_exports.dart';

base mixin CustomMixin<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> request(R request);
}
