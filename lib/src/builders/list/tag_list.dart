import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/tag_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class TagListBuilder implements IQueryBuilder<TagListBuilder, List<Tag>> {
  @override
  Authorization authorization;

  @override
  Callback callback;

  @override
  CancelToken cancelToken;

  @override
  String endpoint;

  @override
  List<Pair<String, String>> headers;

  @override
  List<Pair<String, String>> queryParameters;

  @override
  bool Function(List<Tag>) responseValidationDelegate;

  String _context;
  int _page = 1;
  int _perPage = 10;
  String _search;
  List<int> _exclude;
  List<int> _include;
  String _orderBy;
  String _order;
  List<String> _slug;
  int _post;
  int _offset;
  bool _hideEmpty;

  TagListBuilder withResultOffset(int offset) {
    _offset = offset;
    return this;
  }

  TagListBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  TagListBuilder withPageNumber(int page) {
    _page = page;
    return this;
  }

  TagListBuilder withPerPage(int perPage) {
    _perPage = perPage;
    return this;
  }

  TagListBuilder withSearchQuery(String search) {
    _search = search;
    return this;
  }

  TagListBuilder withExcludedIds(List<int> exclude) {
    _exclude = exclude;
    return this;
  }

  TagListBuilder withIncludedIds(List<int> include) {
    _include = include;
    return this;
  }

  TagListBuilder withOrderBy(FilterCategoryTagSortOrder orderBy) {
    _orderBy = orderBy.toString().split('.').last.toLowerCase();
    return this;
  }

  TagListBuilder withOrder(FilterOrder order) {
    _order = order == FilterOrder.ASCENDING ? 'asc' : 'desc';
    return this;
  }

  TagListBuilder withSlug(List<String> slug) {
    _slug = slug;
    return this;
  }

  TagListBuilder withPost(int post) {
    _post = post;
    return this;
  }

  TagListBuilder withHideEmptyStatus(bool hideEmpty) {
    _hideEmpty = hideEmpty;
    return this;
  }

  @override
  Request<List<Tag>> build() {
    return Request<List<Tag>>(
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

  Map<String, String> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      if (_page != null) 'page': _page.toString(),
      if (_perPage != null) 'per_page': _perPage.toString(),
      if (!isNullOrEmpty(_search)) 'search': _search,
      if (_offset != null && _offset > 0) 'offset': _offset.toString(),
      if (_exclude != null && _exclude.isNotEmpty) 'exclude': _exclude.join(','),
      if (_include != null && _include.isNotEmpty) 'include': _include.join(','),
      if (!isNullOrEmpty(_orderBy)) 'orderby': _orderBy,
      if (!isNullOrEmpty(_order)) 'order': _order,
      if (_slug != null && _slug.isNotEmpty) 'slug': _slug.join(','),
      if (_post != null) 'post': _post.toString(),
      if (_hideEmpty != null && _hideEmpty) 'hide_empty': 'true',
    };
  }

  @override
  TagListBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  TagListBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  TagListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  TagListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  TagListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  TagListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  TagListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  TagListBuilder withResponseValidationOverride(bool Function(List<Tag>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
