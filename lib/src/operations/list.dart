import '../../wordpress_client.dart';

/// Represents the list operation for WordPress API requests.
///
/// This mixin provides methods to retrieve lists of resources using the WordPress API.
/// It is generic over the type [T] of the response data and [R] which extends [IRequest].
base mixin ListOperation<T, R extends IRequest> on IRequestInterface {
  /// Retrieves a list of resources using the provided [request].
  ///
  /// This method sends a list request to the WordPress API and returns
  /// a [WordpressResponse] containing a list of resources of type [T].
  ///
  /// [request] is an instance of [R] that contains the necessary parameters for the list operation,
  /// such as pagination, filtering, or sorting options.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<List<T>>].
  Future<WordpressResponse<List<T>>> list(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.list<T>(wpRequest);
  }

  /// Retrieves a list of resources and returns the raw response for the given [request].
  ///
  /// This method is similar to [list], but instead of parsing the response,
  /// it returns the raw response from the WordPress API.
  ///
  /// [request] is an instance of [R] that contains the necessary parameters for the list operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse].
  /// This can be useful for debugging or when you need access to the full, unprocessed API response.
  Future<WordpressRawResponse> listRaw(
    R request,
  ) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
