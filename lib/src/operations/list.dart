import '../../wordpress_client.dart';

/// Represents the list operation.
base mixin ListOperation<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<List<T>>> list(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.list<T>(wpRequest);
  }

  /// Returns the raw response for the given [request].
  Future<WordpressRawResponse> listRaw(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
