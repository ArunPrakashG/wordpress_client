import '../../../wordpress_client.dart';

final class ListTaxonomyRequest extends IRequest {
  ListTaxonomyRequest({
    this.context,
    this.type,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = false,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// Scope under which the request is made; determines fields present in response.
  /// One of: view, embed, edit. If [RequestContext.edit] is used, auth is required.
  RequestContext? context;

  /// Limit results to taxonomies associated with a specific post type
  /// (e.g., 'post', 'page').
  String? type;

  @override
  WordpressRequest build(Uri baseUrl) {
    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('type', type)
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('taxonomies'),
      requireAuth: requireAuth || context == RequestContext.edit,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
