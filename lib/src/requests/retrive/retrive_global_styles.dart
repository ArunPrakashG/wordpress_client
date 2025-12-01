import '../../../wordpress_client.dart';

/// Retrieve Global Styles (GET /wp/v2/global-styles/<id>)
final class RetrieveGlobalStylesRequest extends IRequest {
  RetrieveGlobalStylesRequest({
    required this.id,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// The global styles identifier (usually theme or a variation id)
  final String id;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{}
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('global-styles/$id'),
      queryParameters: query,
      headers: headers,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
