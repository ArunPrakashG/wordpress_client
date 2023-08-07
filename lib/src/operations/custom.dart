import '../library_exports.dart';

/// Represents the custom operation. This mixin is used to create custom operations.
base mixin CustomMixin<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> request(R request);
}
