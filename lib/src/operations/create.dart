import '../library_exports.dart';

/// Represents the create operation for WordPress API requests.
///
/// This mixin provides methods to create new resources using the WordPress API.
/// It is generic over the type [T] of the response data and [R] which extends [IRequest].
base mixin CreateOperation<T, R extends IRequest> on IRequestInterface {
  /// Creates a new resource using the provided [request].
  ///
  /// This method sends a create request to the WordPress API and returns
  /// a [WordpressResponse] containing the created resource of type [T].
  ///
  /// [request] is an instance of [R] that contains the necessary data for the create operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse<T>].
  Future<WordpressResponse<T>> create(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.create<T>(wpRequest);
  }

  /// Creates a new resource and returns the raw response for the given [request].
  ///
  /// This method is similar to [create], but instead of parsing the response,
  /// it returns the raw response from the WordPress API.
  ///
  /// [request] is an instance of [R] that contains the necessary data for the create operation.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse].
  Future<WordpressRawResponse> createRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
