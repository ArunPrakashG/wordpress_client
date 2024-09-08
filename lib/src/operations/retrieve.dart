import '../../wordpress_client.dart';

/// Represents the retrieve operation for WordPress API requests.
///
/// This mixin provides methods to retrieve data from a WordPress site
/// using the WordPress REST API.
base mixin RetrieveOperation<T, R extends IRequest> on IRequestInterface {
  /// Retrieves data from the WordPress API and returns a typed response.
  ///
  /// [request] is the request object containing the necessary parameters.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse] containing
  /// the retrieved data of type [T].
  Future<WordpressResponse<T>> retrieve(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.retrive<T>(wpRequest);
  }

  /// Retrieves raw data from the WordPress API.
  ///
  /// [request] is the request object containing the necessary parameters.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse] containing
  /// the raw response data from the API.
  Future<WordpressRawResponse> retrieveRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
