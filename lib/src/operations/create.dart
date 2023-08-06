import '../library_exports.dart';

base mixin CreateOperation<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> create(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.create<T>(wpRequest);
  }
}
