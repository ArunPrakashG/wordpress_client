import 'package:dio/dio.dart';

import '../../enums.dart';
import '../../exceptions/null_reference_exception.dart';
import '../../responses/post_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../../wordpress_authorization.dart';
import '../request.dart';
import '../request_builder_base.dart';

class PostListBuilder implements IRequestBuilder<PostListBuilder, List<Post>> {
  PostListBuilder.withEndpoint(String endpoint) {
    if (endpoint == null) {
      throw NullReferenceException('Invalid parameters.');
    }

    endpoint = endpoint;
  }

  static PostListBuilder create() => PostListBuilder();

  PostListBuilder() {}

  String _context;
  int _pageNumber = 1;
  int _perPageCount = 10;
  String _searchQuery;
  DateTime _after;
  DateTime _before;
  List<int> _allowedAuthors;
  List<int> _excludedAuthors;
  List<int> _excludedIds;
  List<int> _allowedIds;
  int _resultOffset = 0;
  String _resultOrder;
  String _sortOrder;
  List<String> _limitBySlug;
  String _limitByStatus;
  String _limitByTaxonomyRelation;
  List<int> _allowedTags;
  List<int> _excludedTags;
  List<int> _allowedCategories;
  List<int> _excludedCategories;
  bool _onlySticky = false;
  bool _emdeded = false;

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
  bool Function(List<Post>) responseValidationDelegate;

  @override
  Callback callback;

  PostListBuilder withAuthorization(WordpressAuthorization auth) {
    if (auth == null || auth.isDefault) {
      return this;
    }

    authorization = auth;
    return this;
  }

  PostListBuilder withHeader(Pair<String, String> customHeader) {
    headers ??= [];
    headers.add(customHeader);
    return this;
  }

  PostListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  PostListBuilder withQueryParameter(Pair<String, String> queryParameter) {
    queryParameters ??= [];
    queryParameters.add(queryParameter);
    return this;
  }

  PostListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  PostListBuilder withResponseValidationOverride(bool Function(List<Post>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  PostListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  PostListBuilder withSearchQuery(String query) {
    _searchQuery = query;
    return this;
  }

  PostListBuilder setEmbeded(bool value) {
    _emdeded = value;
    return this;
  }

  PostListBuilder withPerPage(int count) {
    _perPageCount = count;
    return this;
  }

  PostListBuilder withPageNumber(int pageNumber) {
    _pageNumber = pageNumber;
    return this;
  }

  PostListBuilder withValuesBefore(DateTime dateTime) {
    _before = dateTime;
    return this;
  }

  PostListBuilder withValuesAfter(DateTime dateTime) {
    _after = dateTime;
    return this;
  }

  PostListBuilder withValuesBetween(DateTime start, DateTime end) {
    _before = start;
    _after = end;
    return this;
  }

  PostListBuilder allowAuthors(Iterable<int> ids) {
    _allowedAuthors ??= [];
    _allowedAuthors.addAll(ids);
    return this;
  }

  PostListBuilder excludeAuthors(Iterable<int> ids) {
    _excludedAuthors ??= [];
    _excludedAuthors.addAll(ids);
    return this;
  }

  PostListBuilder includeIds(Iterable<int> ids) {
    _allowedIds ??= [];
    _allowedIds.addAll(ids);
    return this;
  }

  PostListBuilder excludeIds(Iterable<int> ids) {
    _excludedIds ??= [];
    _excludedIds.addAll(ids);
    return this;
  }

  PostListBuilder withResultOffset(int offset) {
    _resultOffset = offset;
    return this;
  }

  PostListBuilder allowSlugs(Iterable<String> slugs) {
    _limitBySlug ??= [];
    _limitBySlug.addAll(slugs);
    return this;
  }

  PostListBuilder orderResultsBy(FilterOrder order) {
    switch (order) {
      case FilterOrder.ASCENDING:
        _resultOrder = 'asc';
        break;
      case FilterOrder.DESCENDING:
        _resultOrder = 'desc';
        break;
    }

    return this;
  }

  PostListBuilder sortResultsBy(FilterPostSortOrder sortOrder) {
    if (isNullOrEmpty(endpoint)) {
      return this;
    }

    if (sortOrder == FilterPostSortOrder.DATE && endpoint.toLowerCase() == 'users') {
      _sortOrder = 'registered_date';
      return this;
    }

    switch (sortOrder) {
      case FilterPostSortOrder.DATE:
      case FilterPostSortOrder.AUTHOR:
      case FilterPostSortOrder.ID:
      case FilterPostSortOrder.INCLUDE:
      case FilterPostSortOrder.MODIFIED:
      case FilterPostSortOrder.PARENT:
      case FilterPostSortOrder.RELEVANCE:
      case FilterPostSortOrder.SLUG:
      case FilterPostSortOrder.TITLE:
        _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        break;
      case FilterPostSortOrder.EMAIL:
        if (endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterPostSortOrder.URL:
        if (endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterPostSortOrder.NAME:
        if (endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterPostSortOrder.INCLUDESLUGS:
        _sortOrder = 'include_slugs';
        break;
    }

    return this;
  }

  PostListBuilder withScope(FilterScope scope) {
    switch (scope) {
      case FilterScope.VIEW:
        _context = 'view';
        break;
      case FilterScope.EMBED:
        _context = 'embed';
        break;
      case FilterScope.EDIT:
        _context = 'edit';
        break;
    }

    return this;
  }

  PostListBuilder limitToSticky(bool shouldLimit) {
    _onlySticky = shouldLimit;
    return this;
  }

  PostListBuilder allowTags(Iterable<int> tags) {
    _allowedTags ??= [];
    _allowedTags.addAll(tags);
    return this;
  }

  PostListBuilder excludeTags(Iterable<int> tags) {
    _excludedTags ??= [];
    _excludedTags.addAll(tags);
    return this;
  }

  PostListBuilder allowCategories(Iterable<int> categories) {
    _allowedCategories ??= [];
    _allowedCategories.addAll(categories);
    return this;
  }

  PostListBuilder excludeCategories(Iterable<int> categories) {
    _excludedCategories ??= [];
    _excludedCategories.addAll(categories);
    return this;
  }

  PostListBuilder setAllowedTaxonomyRelation(TaxonomyRelation relation) {
    switch (relation) {
      case TaxonomyRelation.AND:
        _limitByTaxonomyRelation = 'AND';
        break;
      case TaxonomyRelation.OR:
        _limitByTaxonomyRelation = 'OR';
        break;
    }

    return this;
  }

  PostListBuilder setAllowedStatus(PostAvailabilityStatus status) {
    switch (status) {
      case PostAvailabilityStatus.PUBLISHED:
        _limitByStatus = 'published';
        break;
      case PostAvailabilityStatus.DRAFT:
        _limitByStatus = 'draft';
        break;
      case PostAvailabilityStatus.TRASH:
        _limitByStatus = 'trash';
        break;
    }

    return this;
  }

  Map<String, String> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      if (_pageNumber >= 1) 'page': _pageNumber.toString(),
      if (_perPageCount >= 1) 'per_page': _perPageCount.toString(),
      if (_perPageCount <= 0) 'per_page': '10',
      if (!isNullOrEmpty(_searchQuery)) 'search': _searchQuery,
      if (_emdeded) '_embed': '1',
      if (_after != null) 'after': _after.toIso8601String(),
      if (_before != null) 'before': _before.toIso8601String(),
      if (_allowedAuthors != null && _allowedAuthors.isNotEmpty) 'author': _allowedAuthors.join(','),
      if (_excludedAuthors != null && _excludedAuthors.isNotEmpty) 'author_exclude': _excludedAuthors.join(','),
      if (_allowedIds != null && _allowedIds.isNotEmpty) 'include': _allowedIds.join(','),
      if (_excludedIds != null && _excludedIds.isNotEmpty) 'exclude': _excludedIds.join(','),
      if (_resultOffset > 0) 'offset': _resultOffset.toString(),
      if (!isNullOrEmpty(_sortOrder)) 'orderby': _sortOrder,
      if (!isNullOrEmpty(_resultOrder)) 'order': _resultOrder,
      if (_limitBySlug != null && _limitBySlug.isNotEmpty) 'slug': _limitBySlug.join(','),
      if (!isNullOrEmpty(_limitByStatus)) 'status': _limitByStatus,
      if (!isNullOrEmpty(_limitByTaxonomyRelation)) 'tax_relation': _limitByTaxonomyRelation,
      if (_allowedCategories != null && _allowedCategories.isNotEmpty) 'categories': _allowedCategories.join(','),
      if (_excludedCategories != null && _excludedCategories.isNotEmpty) 'categories_exclude': _excludedCategories.join(','),
      if (_allowedTags != null && _allowedTags.isNotEmpty) 'tags': _allowedTags.join(','),
      if (_excludedTags != null && _excludedTags.isNotEmpty) 'tags_exclude': _excludedTags.join(','),
      if (_onlySticky) 'sticky': '1',
      if (queryParameters != null && queryParameters.isNotEmpty)
        for (var pair in queryParameters)
          if (!isNullOrEmpty(pair.key) && !isNullOrEmpty(pair.value)) pair.key: pair.value
    };
  }

  @override
  Request<List<Post>> build() {
    var req = Request<List<Post>>(
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
    return req;
  }

  @override
  PostListBuilder initializeWithDefaultValues() => this;

  @override
  PostListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  PostListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
