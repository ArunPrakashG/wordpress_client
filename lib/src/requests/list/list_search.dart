import '../../../wordpress_client.dart';

final class ListSearchRequest extends IRequest {
  ListSearchRequest({
    this.context,
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.type,
    this.subType,
    this.subTypes,
    this.include,
    this.exclude,
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

  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  SearchType? type;
  String? subType;
  List<String>? subTypes;
  List<int>? include;
  List<int>? exclude;

  @override
  WordpressRequest build(Uri baseUrl) {
    // Map enum to API value; postFormat -> post-format
    final typeValue = switch (type) {
      SearchType.post => 'post',
      SearchType.term => 'term',
      SearchType.postFormat => 'post-format',
      null => null,
    };

    final queryParameters = <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('type', typeValue)
      ..addIfNotNull('subtype', subType)
      ..addAllIfNotNull(
        subTypes == null ? null : <String, dynamic>{'subtype': subTypes},
      )
      ..addAllIfNotNull(
        include == null ? null : <String, dynamic>{'include': include},
      )
      ..addAllIfNotNull(
        exclude == null ? null : <String, dynamic>{'exclude': exclude},
      )
      ..addAllIfNotNull(extra)
      ..addAllIfNotNull(this.queryParameters);

    return WordpressRequest(
      queryParameters: queryParameters,
      headers: headers,
      method: HttpMethod.get,
      url: RequestUrl.relative('search'),
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
