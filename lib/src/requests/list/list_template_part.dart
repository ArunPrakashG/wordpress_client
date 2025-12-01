import '../../../wordpress_client.dart';

/// List Template Parts (GET /wp/v2/template-parts)
final class ListTemplatePartsRequest extends IRequest {
  ListTemplatePartsRequest({
    this.context,
    this.page,
    this.perPage,
    this.search,
    this.wpId,
    this.area,
    this.postType,
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

  final RequestContext? context;
  final int? page;
  final int? perPage;
  final String? search;
  final int? wpId;
  final String? area;
  final String? postType;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{
      if (context != null) 'context': context!.name,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
      if (search != null) 'search': search,
      if (wpId != null) 'wp_id': wpId,
      if (area != null) 'area': area,
      if (postType != null) 'post_type': postType,
    }
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('template-parts'),
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
