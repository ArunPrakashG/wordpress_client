import '../../wordpress_client.dart';

/// Represents the update operation for WordPress API requests.
///
/// This mixin provides methods to perform update operations on WordPress resources.
/// It is designed to be used with classes that implement [IRequestInterface].
base mixin UpdateOperation<T, R extends IRequest> on IRequestInterface {
  /// Performs an update operation using the provided [request].
  ///
  /// [T] is the type of the expected response data.
  /// [R] is the type of the request, which must extend [IRequest].
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<T>] containing
  /// the updated resource data.
  Future<WordpressResponse<T>> update(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.update<T>(wpRequest);
  }

  /// Performs an update operation and returns the raw response for the given [request].
  ///
  /// This method is useful when you need access to the full, unprocessed API response.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse] containing
  /// the raw API response data.
  Future<WordpressRawResponse> updateRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
