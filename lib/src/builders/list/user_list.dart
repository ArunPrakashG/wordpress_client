import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class UserListBuilder implements IQueryBuilder<UserListBuilder, List<User>> {
  String? _context;
  int _page = 1;
  int _perPage = 10;
  String? _search;
  List<int>? _excludedIds;
  List<int>? _allowedIds;
  int _resultOffset = 0;
  String? _resultOrder;
  String? _sortOrder;
  String? _slug;
  List<String>? _sortRoles;
  bool _limitToAuthors = false;

  @override
  Authorization? authorization;

  @override
  CancelToken? cancelToken;

  @override
  String? endpoint;

  @override
  List<Pair<String, String>>? headers;

  @override
  List<Pair<String, String>>? queryParameters;

  @override
  bool Function(List<User>)? responseValidationDelegate;

  @override
  Callback? callback;

  static UserListBuilder create() => UserListBuilder();

  UserListBuilder();

  UserListBuilder withContext(FilterContext context) {
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
  Request<List<User>> build() {
    return Request<List<User>>(
      endpoint,
      isListRequest: true,
      queryParams: _parseQueryParameters(),
      callback: callback,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      headers: headers,
      formBody: null,
      httpMethod: HttpMethod.GET,
      authorization: authorization,
    );
  }

  Map<String, String?> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      if (_page > 0) 'page': _page.toString(),
      if (_perPage > 0) 'per_page': _perPage.toString(),
      if (!isNullOrEmpty(_search)) 'search': _search,
      if (_excludedIds != null && _excludedIds!.isNotEmpty) 'exclude': _excludedIds.toString(),
      if (_allowedIds != null && _allowedIds!.isNotEmpty) 'include': _allowedIds.toString(),
      if (_resultOffset > 0) 'offset': _resultOffset.toString(),
      if (!isNullOrEmpty(_resultOrder)) 'order': _resultOrder,
      if (!isNullOrEmpty(_sortOrder)) 'orderby': _sortOrder,
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
      if (_limitToAuthors) 'who': 'authors',
      if (_sortRoles != null && _sortRoles!.isNotEmpty) 'roles': _sortRoles.toString(),
    };
  }

  @override
  UserListBuilder initializeWithDefaultValues() => this;

  @override
  UserListBuilder withAuthorization(Authorization auth) {
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
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  UserListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserListBuilder withResponseValidationOverride(bool Function(List<User>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  UserListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
