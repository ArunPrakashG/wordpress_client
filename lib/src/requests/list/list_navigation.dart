import '../../../wordpress_client.dart';

/// List Navigations (GET /wp/v2/navigation)
///
/// Docs: https://developer.wordpress.org/rest-api/reference/wp_navigations/#list-navigations
final class ListNavigationsRequest extends IRequest {
  ListNavigationsRequest({
    this.context,
    this.page,
    this.perPage,
    this.search,
    this.after,
    this.modifiedAfter,
    this.before,
    this.modifiedBefore,
    this.exclude,
    this.include,
    this.offset,
    this.order,
    this.orderby,
    this.searchColumns,
    this.slug,
    this.status,
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
  final DateTime? after;
  final DateTime? modifiedAfter;
  final DateTime? before;
  final DateTime? modifiedBefore;
  final List<int>? exclude;
  final List<int>? include;
  final int? offset;
  final Order? order;
  final OrderBy? orderby;
  final List<String>? searchColumns;
  final List<String>? slug;
  final List<ContentStatus>? status;

  @override
  WordpressRequest build(Uri baseUrl) {
    final query = <String, dynamic>{
      if (context != null) 'context': context!.name,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
      if (search != null) 'search': search,
      if (after != null) 'after': after!.toIso8601String(),
      if (modifiedAfter != null)
        'modified_after': modifiedAfter!.toIso8601String(),
      if (before != null) 'before': before!.toIso8601String(),
      if (modifiedBefore != null)
        'modified_before': modifiedBefore!.toIso8601String(),
      if (exclude != null) 'exclude': exclude,
      if (include != null) 'include': include,
      if (offset != null) 'offset': offset,
      if (order != null) 'order': order!.name,
      if (orderby != null) 'orderby': orderby!.name,
      if (searchColumns != null) 'search_columns': searchColumns,
      if (slug != null) 'slug': slug,
      if (status != null) 'status': status!.map((s) => s.name).toList(),
    }
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.get,
      url: RequestUrl.relative('navigation'),
      headers: headers,
      queryParameters: query,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
