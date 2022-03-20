import '../../../wordpress_client.dart';

class ListSearchRequest extends IRequest {
  RequestContext? context;
  int page = 1;
  int perPage = 10;
  String? search;
  SearchType? type;
  String? subType;

  @override
  void build(RequestContent requestContent) {
    requestContent.queryParameters
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('page', page)
      ..addIfNotNull('per_page', perPage)
      ..addIfNotNull('search', search)
      ..addIfNotNull('type', type?.name)
      ..addIfNotNull('subtype', subType);

    requestContent.endpoint = 'search';
    requestContent.method = HttpMethod.get;
  }
}
