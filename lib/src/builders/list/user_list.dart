import 'package:dio/src/cancel_token.dart';
import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/requests/builders/request_builder_base.dart';
import 'package:wordpress_client/src/requests/request.dart';
import 'package:wordpress_client/src/utilities/helpers.dart';
import 'package:wordpress_client/src/wordpress_authorization.dart';
import 'package:wordpress_client/src/utilities/pair.dart';

class UserListBuilder implements IRequestBuilder<UserListBuilder, Request> {
  String _context;
  int _page = 1;
  int _perPage = 10;
  String _search;
  List<int> _excludedIds;
  List<int> _allowedIds;
  int _resultOffset = 0;
  String _resultOrder;
  String _sortOrder;
  String _slug;
  List<String> _sortRoles;
  bool _limitToAuthors = false;

  @override
  WordpressAuthorization authorization;

  @override
  CancelToken cancelToken;

  @override
  String endpoint;

  @override
  List<Pair<String, String>> headers;

  @override
  List<Pair<String, String>> queryParameters;

  @override
  bool Function(Map<String, dynamic> p1) responseValidationDelegate;

  static UserListBuilder create() => UserListBuilder();

  UserListBuilder();

  UserListBuilder withContext(FilterScope context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  UserListBuilder withPageNumber(int page) {
    _page = page;
    return this;
  }

  UserListBuilder withPerPage(int perPage) {
    _perPage = perPage;
    return this;
  }

  UserListBuilder withSearchQuery(String search) {
    _search = search;
    return this;
  }

  UserListBuilder withExcludedIds(List<int> excludedIds) {
    _excludedIds = excludedIds;
    return this;
  }

  UserListBuilder withAllowedIds(List<int> allowedIds) {
    _allowedIds = allowedIds;
    return this;
  }

  UserListBuilder withResultOffset(int offset) {
    _resultOffset = offset;
    return this;
  }

  UserListBuilder withResultOrder(FilterOrder order) {
    _resultOrder = order == FilterOrder.ASCENDING ? 'asc' : 'desc';
    return this;
  }

  UserListBuilder withSortOrder(FilterUserSortOrder order) {
    _sortOrder = order.toString().split('.').last.toLowerCase();
    return this;
  }

  UserListBuilder withSlug(String slug) {
    slug = slug;
    return this;
  }

  UserListBuilder withSortRoles(List<String> roles) {
    _sortRoles = roles;
    return this;
  }

  UserListBuilder withLimitToAuthors(bool limitToAuthors) {
    _limitToAuthors = limitToAuthors;
    return this;
  }

  @override
  Request build() {
    return Request(
      endpoint,
      isListRequest: true,
      queryParams: _parseQueryParameters(),
      callback: null,
      cancelToken: cancelToken,
      headers: headers,
      formBody: null,
      httpMethod: HttpMethod.GET,
      authorization: authorization,
    );
  }

  Map<String, String> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      if (_page > 0) 'page': _page.toString(),
      if (_perPage > 0) 'per_page': _perPage.toString(),
      if (!isNullOrEmpty(_search)) 'search': _search,
      if (_excludedIds != null && _excludedIds.isNotEmpty) 'exclude': _excludedIds.toString(),
      if (_allowedIds != null && _allowedIds.isNotEmpty) 'include': _allowedIds.toString(),
      if (_resultOffset > 0) 'offset': _resultOffset.toString(),
      if (!isNullOrEmpty(_resultOrder)) 'order': _resultOrder,
      if (!isNullOrEmpty(_sortOrder)) 'orderby': _sortOrder,
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
      if (_limitToAuthors) 'who': 'authors',
      if (_sortRoles != null && _sortRoles.isNotEmpty) 'roles': _sortRoles.toString(),
    };
  }

  @override
  UserListBuilder initializeWithDefaultValues() => this;

  @override
  UserListBuilder withAuthorization(WordpressAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  UserListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  UserListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  UserListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  UserListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserListBuilder withResponseValidationOverride(bool Function(Map<String, dynamic> p1) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
