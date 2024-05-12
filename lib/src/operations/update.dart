import '../../wordpress_client.dart';

/// Represents the update operation.
base mixin UpdateOperation<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> update(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.update<T>(wpRequest);
  }

  /// Returns the raw response for the given [request].
  Future<WordpressRawResponse> updateRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
