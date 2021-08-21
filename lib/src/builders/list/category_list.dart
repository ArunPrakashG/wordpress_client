import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/category_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CategoryListBuilder
    implements IQueryBuilder<CategoryListBuilder, List<Category>> {
  @override
  IAuthorization? authorization;

  @override
  Callback? callback;

  @override
  CancelToken? cancelToken;

  @override
  String? endpoint;

  @override
  List<Pair<String, String>>? headers;

  @override
  List<Pair<String, String>>? queryParameters;

  @override
  bool Function(List<Category>)? responseValidationDelegate;

  String? _context;
  int _page = 1;
  int _perPage = 10;
  String? _search;
  List<int>? _exclude;
  List<int>? _include;
  String? _orderBy;
  String? _order;
  List<String>? _slug;
  int? _parent;
  int? _post;
  bool? _hideEmpty;

  CategoryListBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  CategoryListBuilder withPageNumber(int page) {
    _page = page;
    return this;
  }

  CategoryListBuilder withPerPage(int perPage) {
    _perPage = perPage;
    return this;
  }

  CategoryListBuilder withSearchQuery(String search) {
    _search = search;
    return this;
  }

  CategoryListBuilder withExcludedIds(List<int> exclude) {
    _exclude = exclude;
    return this;
  }

  CategoryListBuilder withIncludedIds(List<int> include) {
    _include = include;
    return this;
  }

  CategoryListBuilder withOrderBy(FilterCategoryTagSortOrder orderBy) {
    _orderBy = orderBy.toString().split('.').last.toLowerCase();
    return this;
  }

  CategoryListBuilder withOrder(FilterOrder order) {
    _order = order == FilterOrder.ASCENDING ? 'asc' : 'desc';
    return this;
  }

  CategoryListBuilder withSlug(List<String> slug) {
    _slug = slug;
    return this;
  }

  CategoryListBuilder withParent(int parent) {
    _parent = parent;
    return this;
  }

  CategoryListBuilder withPost(int post) {
    _post = post;
    return this;
  }

  CategoryListBuilder withHideEmptyStatus(bool hideEmpty) {
    _hideEmpty = hideEmpty;
    return this;
  }

  @override
  Request<List<Category>> build() {
    return Request<List<Category>>(
      endpoint,
      isListRequest: true,
      callback: callback,
      httpMethod: HttpMethod.GET,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      queryParams: _parseQueryParameters(),
    );
  }

  Map<String, String?> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      'page': _page.toString(),
      'per_page': _perPage.toString(),
      if (!isNullOrEmpty(_search)) 'search': _search,
      if (_exclude != null && _exclude!.isNotEmpty)
        'exclude': _exclude!.join(','),
      if (_include != null && _include!.isNotEmpty)
        'include': _include!.join(','),
      if (!isNullOrEmpty(_orderBy)) 'orderby': _orderBy,
      if (!isNullOrEmpty(_order)) 'order': _order,
      if (_slug != null && _slug!.isNotEmpty) 'slug': _slug!.join(','),
      if (_parent != null) 'parent': _parent.toString(),
      if (_post != null) 'post': _post.toString(),
      if (_hideEmpty != null && _hideEmpty!) 'hide_empty': 'true',
    };
  }

  @override
  CategoryListBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CategoryListBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CategoryListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  CategoryListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CategoryListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CategoryListBuilder withHeaders(
      Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CategoryListBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CategoryListBuilder withResponseValidationOverride(
      bool Function(List<Category>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
