import '../library_exports.dart';

/// Represents the custom operation. This mixin is used to create custom operations.
base mixin CustomOperation<T, R extends IRequest> on IRequestInterface {
  T decode(dynamic json);

  Future<WordpressResponse<T>> request(R request) async {
    final wpRequest = await request.build(baseUrl);

    // ignore: invalid_use_of_protected_member
    final response = await executor.execute(wpRequest);

    return response.asResponse<T>(decoder: decode);
  }
}
