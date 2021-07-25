import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/comment_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CommentListBuilder implements IQueryBuilder<CommentListBuilder, List<Comment>> {
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
  bool Function(List<Comment>) responseValidationDelegate;

  String _context;
  int _page = 1;
  int _perPage = 10;
  String _search;
  DateTime _after;
  DateTime _before;
  List<int> _exclude;
  List<int> _include;
  String _orderBy;
  String _order;
  List<int> _allowedAuthors;
  List<int> _excludedAuthors;
  int _offset;
  List<int> _allowedParents;
  List<int> _excludedParents;
  List<int> _allowedPosts;
  String _status = 'approve';
  String _type = 'comment';
  String _password;

  CommentListBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  CommentListBuilder withPageNumber(int page) {
    _page = page;
    return this;
  }

  CommentListBuilder withPerPage(int perPage) {
    _perPage = perPage;
    return this;
  }

  CommentListBuilder withSearchQuery(String search) {
    _search = search;
    return this;
  }

  CommentListBuilder withExcludedIds(List<int> exclude) {
    _exclude = exclude;
    return this;
  }

  CommentListBuilder withIncludedIds(List<int> include) {
    _include = include;
    return this;
  }

  CommentListBuilder withOrderBy(FilterCategoryTagSortOrder orderBy) {
    _orderBy = orderBy.toString().split('.').last.toLowerCase();
    return this;
  }

  CommentListBuilder withOrder(FilterOrder order) {
    _order = order == FilterOrder.ASCENDING ? 'asc' : 'desc';
    return this;
  }

  CommentListBuilder withAllowedAuthors(List<int> allowedAuthors) {
    _allowedAuthors ??= [];
    _allowedAuthors.addAll(allowedAuthors);
    return this;
  }

  CommentListBuilder withExcludedAuthors(List<int> excludedAuthors) {
    _excludedAuthors ??= [];
    _excludedAuthors.addAll(excludedAuthors);
    return this;
  }

  CommentListBuilder withOffset(int offset) {
    _offset = offset;
    return this;
  }

  CommentListBuilder withAllowedParents(List<int> allowedParents) {
    _allowedParents ??= [];
    _allowedParents.addAll(allowedParents);
    return this;
  }

  CommentListBuilder withExcludedParents(List<int> excludedParents) {
    _excludedParents ??= [];
    _excludedParents.addAll(excludedParents);
    return this;
  }

  CommentListBuilder withAllowedPosts(List<int> allowedPosts) {
    _allowedPosts ??= [];
    _allowedPosts.addAll(allowedPosts);
    return this;
  }

  CommentListBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  CommentListBuilder withBefore(DateTime before) {
    _before = before;
    return this;
  }

  CommentListBuilder withAfter(DateTime after) {
    _after = after;
    return this;
  }

  @override
  Request<List<Comment>> build() {
    return Request<List<Comment>>(
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
      if (_exclude != null && _exclude.isNotEmpty) 'exclude': _exclude.join(','),
      if (_include != null && _include.isNotEmpty) 'include': _include.join(','),
      if (!isNullOrEmpty(_orderBy)) 'orderby': _orderBy,
      if (!isNullOrEmpty(_order)) 'order': _order,
      if (_allowedAuthors != null && _allowedAuthors.isNotEmpty) 'author': _allowedAuthors.join(','),
      if (_excludedAuthors != null && _excludedAuthors.isNotEmpty) 'author_exclude': _excludedAuthors.join(','),
      if (_offset != null) 'offset': _offset.toString(),
      if (_allowedParents != null && _allowedParents.isNotEmpty) 'parent': _allowedParents.join(','),
      if (_excludedParents != null && _excludedParents.isNotEmpty) 'parent_exclude': _excludedParents.join(','),
      if (_allowedPosts != null && _allowedPosts.isNotEmpty) 'post': _allowedPosts.join(','),
      if (!isNullOrEmpty(_status)) 'status': _status,
      if (!isNullOrEmpty(_type)) 'type': _type,
      if (!isNullOrEmpty(_password)) 'password': _password,
      if (_before != null) 'before': _before.toIso8601String(),
      if (_after != null) 'after': _after.toIso8601String(),
    };
  }

  @override
  CommentListBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CommentListBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CommentListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  CommentListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CommentListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CommentListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  CommentListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  CommentListBuilder withResponseValidationOverride(bool Function(List<Comment>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
