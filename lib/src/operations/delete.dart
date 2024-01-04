import '../library_exports.dart';

/// Represents the delete operation.
base mixin DeleteOperation<R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<bool>> delete(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.delete(wpRequest);
  }

  /// Returns the raw response for the given [request].
  ///
  /// **Note that for delete responses, Wordpress API returns an empty response body.**
  Future<WordpressRawResponse> deleteRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.execute(wpRequest);
  }
}
