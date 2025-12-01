import '../library_exports.dart';

/// Represents the delete operation for WordPress API requests.
///
/// This mixin provides methods to delete resources using the WordPress API.
/// It is generic over [R] which extends [IRequest].
base mixin DeleteOperation<R extends IRequest> on IRequestInterface {
  /// Deletes a resource using the provided [request].
  ///
  /// This method sends a delete request to the WordPress API and returns
  /// a [WordpressResponse] containing a boolean indicating the success of the operation.
  ///
  /// [request] is an instance of [R] that contains the necessary data for the delete operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<bool>].
  /// The boolean value is typically true if the deletion was successful.
  Future<WordpressResponse<bool>> delete(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.delete(wpRequest);
  }

  /// Deletes a resource and returns the raw response for the given [request].
  ///
  /// This method is similar to [delete], but instead of parsing the response,
  /// it returns the raw response from the WordPress API.
  ///
  /// [request] is an instance of [R] that contains the necessary data for the delete operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse].
  ///
  /// **Note: For delete operations, the WordPress API typically returns an empty response body.**
  Future<WordpressRawResponse> deleteRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
