import '../library_exports.dart';

/// Represents the custom operation. This mixin is used to create custom operations.
base mixin CustomOperation<T, R extends IRequest> on IRequestInterface {
  T decode(dynamic json);

  /// Executes the given [request] and returns the response.
  Future<WordpressResponse<T>> request(R request) async {
    final wpRequest = await request.build(baseUrl);

    final response = await executor.execute(wpRequest);

    return response.asResponse<T>(decoder: decode);
  }

  /// Returns the raw response for the given [request].
  Future<WordpressRawResponse> requestRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.execute(wpRequest);
  }
}
