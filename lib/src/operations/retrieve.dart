import '../../wordpress_client.dart';

/// Represents the retrive operation.
base mixin RetriveOperation<T, R extends IRequest> on IRequestInterface {
  Future<WordpressResponse<T>> retrive(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.retrive<T>(wpRequest);
  }

  /// Returns the raw response for the given [request].
  Future<WordpressRawResponse> retriveRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.execute(wpRequest);
  }
}
