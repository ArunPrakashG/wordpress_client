import '../../../wordpress_client.dart';

/// List Template Revisions (GET /wp/v2/templates/<parent>/revisions)
final class ListTemplateRevisionsRequest extends IRequest {
  ListTemplateRevisionsRequest({
    required this.parent,
    this.context,
    this.page,
    this.perPage,
    this.search,
    this.exclude,
    this.include,
    this.offset,
    this.order,
    this.orderby,
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

  /// The ID for the parent of the revision (template wp_id).
  final int parent;
  final RequestContext? context;
  final int? page;
  final int? perPage;
  final String? search;
  final List<int>? exclude;
  final List<int>? include;
  final int? offset;
  final Order? order;
  final OrderBy? orderby;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{
      if (context != null) 'context': context!.name,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
      if (search != null) 'search': search,
      if (exclude != null) 'exclude': exclude,
      if (include != null) 'include': include,
      if (offset != null) 'offset': offset,
      if (order != null) 'order': order!.name,
      if (orderby != null) 'orderby': orderby!.name,
    }
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('templates/$parent/revisions'),
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
