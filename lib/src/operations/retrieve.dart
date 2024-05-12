import '../../wordpress_client.dart';

/// Represents the retrive operation.
base mixin RetrieveOperation<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> retrieve(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.retrive<T>(wpRequest);
  }

  /// Returns the raw response for the given [request].
  Future<WordpressRawResponse> retrieveRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }
}
