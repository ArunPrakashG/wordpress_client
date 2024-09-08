import '../library_exports.dart';

/// Represents a custom operation for interacting with WordPress APIs.
/// This mixin is used to create custom operations that can execute requests
/// and handle responses.
base mixin CustomOperation<T, R extends IRequest> on IRequestInterface {
  /// Decodes the JSON response into the desired type [T].
  /// Implement this method to define how the API response should be parsed.
  T decode(dynamic json);

  /// Executes the given [request] and returns a typed response.
  ///
  /// This method performs the following steps:
  /// 1. Builds the WordPress request using the provided [request] object.
  /// 2. Executes the request using the [executor].
  /// 3. Decodes the response using the [decode] method.
  ///
  /// Returns a [WordpressResponse] containing the decoded data of type [T].
  Future<WordpressResponse<T>> request(R request) async {
    final wpRequest = await request.build(baseUrl);

    final response = await executor.execute(wpRequest);

    return response.asResponse<T>(decoder: decode);
  }

  /// Returns the raw response for the given [request] without decoding.
  ///
  /// This method is useful when you need access to the unprocessed API response.
  /// It performs the following steps:
  /// 1. Builds the WordPress request using the provided [request] object.
  /// 2. Executes the request using the [executor] in raw mode.
  ///
  /// Returns a [WordpressRawResponse] containing the unprocessed API response.
  Future<WordpressRawResponse> raw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
