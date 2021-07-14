import 'package:dio/dio.dart';
import 'package:wordpress_client/src/exceptions/null_reference_exception.dart';
import 'package:wordpress_client/src/utilities/helpers.dart';
import 'package:wordpress_client/src/utilities/pair.dart';

import '../../enums.dart';
import '../../wordpress_authorization.dart';
import '../request.dart';
import 'request_builder_base.dart';

class RetriveRequestBuilder implements IRequestBuilder<RetriveRequestBuilder, Request> {
  RetriveRequestBuilder.withValues(String endpoint) {
    if (endpoint == null) {
      throw NullReferenceException('Invalid parameters.');
    }

    _endpoint = endpoint;
  }

  static RetriveRequestBuilder create() => RetriveRequestBuilder();

  RetriveRequestBuilder();

  String _endpoint;
  CancelToken _cancelToken;
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
  WordpressAuthorization _authorization;
  bool Function(Map<String, dynamic>) _responseValidationDelegate;
  List<Pair<String, String>> _headers;
  List<Pair<String, String>> _queryParameters;

  RetriveRequestBuilder withAuthorization(WordpressAuthorization authorization) {
    if (authorization == null || authorization.isDefault) {
      return this;
    }

    _authorization = authorization;
    return this;
  }

  RetriveRequestBuilder withHeader(Pair<String, String> header) {
    _headers ??= [];
    _headers.add(header);
    return this;
  }

  RetriveRequestBuilder withHeaders(Iterable<Pair<String, String>> headers) {
    _headers ??= [];
    _headers.addAll(headers);
    return this;
  }

  RetriveRequestBuilder withQueryParameter(Pair<String, String> queryParameter) {
    _queryParameters ??= [];
    _queryParameters.add(queryParameter);
    return this;
  }

  RetriveRequestBuilder withQueryParameters(Iterable<Pair<String, String>> queryParameters) {
    _queryParameters ??= [];
    _queryParameters.addAll(queryParameters);
    return this;
  }

  RetriveRequestBuilder withResponseValidationOverride(bool Function(Map<String, dynamic>) responseDelegate) {
    _responseValidationDelegate = responseDelegate;
    return this;
  }

  RetriveRequestBuilder withCancellationToken(CancelToken token) {
    _cancelToken = token;
    return this;
  }

  RetriveRequestBuilder withSearchQuery(String query) {
    _searchQuery = query;
    return this;
  }

  RetriveRequestBuilder setEmbeded(bool value) {
    _emdeded = value;
    return this;
  }

  RetriveRequestBuilder withPerPage(int count) {
    _perPageCount = count;
    return this;
  }

  RetriveRequestBuilder withPageNumber(int pageNumber) {
    _pageNumber = pageNumber;
    return this;
  }

  RetriveRequestBuilder withValuesBefore(DateTime dateTime) {
    _before = dateTime;
    return this;
  }

  RetriveRequestBuilder withValuesAfter(DateTime dateTime) {
    _after = dateTime;
    return this;
  }

  RetriveRequestBuilder withValuesBetween(DateTime start, DateTime end) {
    _before = start;
    _after = end;
    return this;
  }

  RetriveRequestBuilder allowAuthors(Iterable<int> ids) {
    _allowedAuthors ??= [];
    _allowedAuthors.addAll(ids);
    return this;
  }

  RetriveRequestBuilder excludeAuthors(Iterable<int> ids) {
    _excludedAuthors ??= [];
    _excludedAuthors.addAll(ids);
    return this;
  }

  RetriveRequestBuilder includeIds(Iterable<int> ids) {
    _allowedIds ??= [];
    _allowedIds.addAll(ids);
    return this;
  }

  RetriveRequestBuilder excludeIds(Iterable<int> ids) {
    _excludedIds ??= [];
    _excludedIds.addAll(ids);
    return this;
  }

  RetriveRequestBuilder withResultOffset(int offset) {
    _resultOffset = offset;
    return this;
  }

  RetriveRequestBuilder allowSlugs(Iterable<String> slugs) {
    _limitBySlug ??= [];
    _limitBySlug.addAll(slugs);
    return this;
  }

  RetriveRequestBuilder orderResultsBy(FilterOrder order) {
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

  RetriveRequestBuilder sortResultsBy(FilterSortOrder sortOrder) {
    if (isNullOrEmpty(_endpoint)) {
      return this;
    }

    if (sortOrder == FilterSortOrder.DATE && _endpoint.toLowerCase() == 'users') {
      _sortOrder = 'registered_date';
      return this;
    }

    switch (sortOrder) {
      case FilterSortOrder.DATE:
      case FilterSortOrder.AUTHOR:
      case FilterSortOrder.ID:
      case FilterSortOrder.INCLUDE:
      case FilterSortOrder.MODIFIED:
      case FilterSortOrder.PARENT:
      case FilterSortOrder.RELEVANCE:
      case FilterSortOrder.SLUG:
      case FilterSortOrder.TITLE:
        _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        break;
      case FilterSortOrder.EMAIL:
        if (_endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.URL:
        if (_endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.NAME:
        if (_endpoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.INCLUDESLUGS:
        _sortOrder = 'include_slugs';
        break;
    }

    return this;
  }

  RetriveRequestBuilder withScope(FilterScope scope) {
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

  RetriveRequestBuilder limitToSticky(bool shouldLimit) {
    _onlySticky = shouldLimit;
    return this;
  }

  RetriveRequestBuilder allowTags(Iterable<int> tags) {
    _allowedTags ??= [];
    _allowedTags.addAll(tags);
    return this;
  }

  RetriveRequestBuilder excludeTags(Iterable<int> tags) {
    _excludedTags ??= [];
    _excludedTags.addAll(tags);
    return this;
  }

  RetriveRequestBuilder allowCategories(Iterable<int> categories) {
    _allowedCategories ??= [];
    _allowedCategories.addAll(categories);
    return this;
  }

  RetriveRequestBuilder excludeCategories(Iterable<int> categories) {
    _excludedCategories ??= [];
    _excludedCategories.addAll(categories);
    return this;
  }

  RetriveRequestBuilder setAllowedTaxonomyRelation(TaxonomyRelation relation) {
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

  RetriveRequestBuilder setAllowedStatus(PostAvailabilityStatus status) {
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
      if (_queryParameters != null && _queryParameters.isNotEmpty)
        for (var pair in _queryParameters)
          if (!isNullOrEmpty(pair.key) && !isNullOrEmpty(pair.value)) pair.key: pair.value
    };
  }

  @override
  Request build() {
    return Request(
      _endpoint,
      callback: null,
      httpMethod: HttpMethod.GET,
      validationDelegate: _responseValidationDelegate,
      cancelToken: _cancelToken,
      authorization: _authorization,
      headers: _headers,
      queryParams: _parseQueryParameters(),
    );
  }

  @override
  RetriveRequestBuilder initializeWithDefaultValues() {
    // TODO: implement initializeWithDefaultValues
    throw UnimplementedError();
  }
}
