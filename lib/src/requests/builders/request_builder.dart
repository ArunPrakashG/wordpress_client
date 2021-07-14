import 'package:dio/dio.dart';
import 'package:wordpress_client/src/exceptions/null_reference_exception.dart';
import 'package:wordpress_client/src/requests/builders/media_builder.dart';
import 'package:wordpress_client/src/requests/builders/post_builder.dart';
import 'package:wordpress_client/src/utilities/helpers.dart';
import 'package:wordpress_client/src/utilities/pair.dart';
import 'package:wordpress_client/src/wordpress_authorization.dart';
import '../../utilities/callback.dart';
import '../../enums.dart';
import '../request.dart';
import 'request_builder_base.dart';

class RequestBuilder implements IRequestBuilder<RequestBuilder, Request> {
  RequestBuilder.withValues(String requestUrlBase, String endpoint) {
    if (requestUrlBase == null || endpoint == null) {
      throw NullReferenceException('Invalid parameters.');
    }

    if (!requestUrlBase.endsWith('/')) {
      requestUrlBase = '$requestUrlBase/';
    }

    final requestUri = Uri.tryParse('$requestUrlBase$endpoint');

    if (requestUri == null) {
      throw Exception('Failed to parse urls. $requestUrlBase $endpoint');
    }

    _baseUri = requestUri;
    _endpoint = endpoint;
  }

  static RequestBuilder create() => RequestBuilder();

  RequestBuilder();

  Uri _baseUri;
  Uri _requestUri;
  CancelToken _cancelToken;
  String _endpoint;
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
  HttpMethod _httpMethod = HttpMethod.GET;
  List<Pair<String, String>> _headers;
  List<Pair<String, String>> _queryParameters;
  Map<String, dynamic> _formBody;
  String _deleteRequestUrl;

  bool get isDeleteRequest => _deleteRequestUrl != null && _deleteRequestUrl.isNotEmpty;

  static String _getJoiningChar(String baseUrl) {
    if (baseUrl == null || baseUrl.isEmpty) {
      return '';
    }

    if ((baseUrl.contains('?') && !baseUrl.contains('&')) || baseUrl.contains('?') && baseUrl.contains('&')) {
      return '&';
    }

    if (baseUrl.contains('?') && baseUrl.contains('&')) {
      return '&';
    }

    if (!baseUrl.contains('?')) {
      return '?';
    }

    return '&';
  }

  bool _createUri() {
    var baseUrl = _baseUri.toString();

    if (isDeleteRequest) {
      baseUrl += _deleteRequestUrl;
    } else {
      baseUrl = _appendUriParts(baseUrl);
    }

    final reqUriParsed = Uri.tryParse(baseUrl);

    if (reqUriParsed == null) {
      return false;
    }

    _requestUri = reqUriParsed;
    return true;
  }

  String _appendUriParts(String baseUrl) {
    if (_formBody != null) {
      return baseUrl;
    }

    if (!isNullOrEmpty(_context)) {
      baseUrl += '${_getJoiningChar(baseUrl)}context=$_context';
    }

    if (_pageNumber >= 1) {
      baseUrl += '${_getJoiningChar(baseUrl)}page=$_pageNumber';
    }

    if (_perPageCount >= 1) {
      baseUrl += '${_getJoiningChar(baseUrl)}per_page=$_perPageCount';
    }

    if (_perPageCount <= 0) {
      baseUrl += '${_getJoiningChar(baseUrl)}per_page=10';
    }

    if (!isNullOrEmpty(_searchQuery)) {
      baseUrl += '${_getJoiningChar(baseUrl)}search=$_searchQuery';
    }

    if (_emdeded) {
      baseUrl += '${_getJoiningChar(baseUrl)}_embed=1';
    }

    if (_after != null) {
      baseUrl += '${_getJoiningChar(baseUrl)}after=${_after.toIso8601String()}';
    }

    if (_before != null) {
      baseUrl += '${_getJoiningChar(baseUrl)}before=${_before.toIso8601String()}';
    }

    if (_allowedAuthors != null && _allowedAuthors.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}author=${_allowedAuthors.join(',')}';
    }

    if (_excludedAuthors != null && _excludedAuthors.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}author_exclude=${_excludedAuthors.join(',')}';
    }

    if (_allowedIds != null && _allowedIds.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}include=${_allowedIds.join(',')}';
    }

    if (_excludedIds != null && _excludedIds.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}exclude=${_excludedIds.join(',')}';
    }

    if (_resultOffset > 0) {
      baseUrl += '${_getJoiningChar(baseUrl)}offset=$_resultOffset';
    }

    if (!isNullOrEmpty(_sortOrder)) {
      baseUrl += '${_getJoiningChar(baseUrl)}orderby=$_sortOrder';
    }

    if (!isNullOrEmpty(_resultOrder)) {
      baseUrl += '${_getJoiningChar(baseUrl)}order=$_resultOrder';
    }

    if (_limitBySlug != null && _limitBySlug.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}slug=${_limitBySlug.join(',')}';
    }

    if (!isNullOrEmpty(_limitByStatus)) {
      baseUrl += '${_getJoiningChar(baseUrl)}status=$_limitByStatus';
    }

    if (!isNullOrEmpty(_limitByTaxonomyRelation)) {
      baseUrl += '${_getJoiningChar(baseUrl)}tax_relation=$_limitByTaxonomyRelation';
    }

    if (_allowedCategories != null && _allowedCategories.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}categories=${_allowedCategories.join(',')}';
    }

    if (_excludedCategories != null && _excludedCategories.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}categories_exclude=${_excludedCategories.join(',')}';
    }

    if (_allowedTags != null && _allowedTags.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}tags=${_allowedTags.join(',')}';
    }

    if (_excludedTags != null && _excludedTags.isNotEmpty) {
      baseUrl += '${_getJoiningChar(baseUrl)}tags_exclude=${_excludedTags.join(',')}';
    }

    if (_onlySticky) {
      baseUrl += '${_getJoiningChar(baseUrl)}sticky=1';
    }

    if (_queryParameters != null && _queryParameters.isNotEmpty) {
      for (final pair in _queryParameters) {
        if (isNullOrEmpty(pair.key) || isNullOrEmpty(pair.value)) {
          continue;
        }

        baseUrl += '${_getJoiningChar(baseUrl)}${pair.key}=${pair.value}';
      }
    }

    return baseUrl;
  }

  RequestBuilder withBaseAndEndpoint(String requestUrlBase, String endpoint) {
    if (isNullOrEmpty(requestUrlBase)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(endpoint)) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    final requestUri = Uri.tryParse(parseUrl(requestUrlBase, endpoint));

    if (requestUri == null) {
      throw Exception('Failed to parse urls. $requestUrlBase $endpoint');
    }

    _baseUri = requestUri;
    _endpoint = endpoint;
    return this;
  }

  RequestBuilder withUri(Uri requestUri) {
    _baseUri = requestUri;
    return this;
  }

  RequestBuilder withPostBody(Map<String, dynamic> Function(PostBuilder) builder) {
    _formBody = builder(PostBuilder().initializeWithDefaultValues());
    return this;
  }

  RequestBuilder withMediaBody(Map<String, dynamic> Function(MediaBuilder) builder) {
    _formBody = builder(MediaBuilder().initializeWithDefaultValues());
    return this;
  }

  RequestBuilder withHttpBody<T1 extends IRequestBuilder<T1, T2>, T2 extends Map<String, dynamic>>(T1 instance, T2 Function(T1) builder) {
    _formBody = builder(instance.initializeWithDefaultValues());
    return this;
  }

  RequestBuilder withQueryParameters<T1 extends IRequestBuilder<T1, T2>, T2 extends Iterable<Pair<String, String>>>(
      T1 instance, T2 Function(T1) builder) {
    _queryParameters ??= [];
    _queryParameters.addAll(builder(instance.initializeWithDefaultValues()));

    return this;
  }

  RequestBuilder withAuthorization(WordpressAuthorization authorization) {
    if (authorization == null || authorization.isDefault) {
      return this;
    }

    _authorization = authorization;
    return this;
  }

  RequestBuilder withHeader(Pair<String, String> header) {
    _headers ??= [];
    _headers.add(header);
    return this;
  }

  RequestBuilder withHeaders(Iterable<Pair<String, String>> headers) {
    _headers ??= [];
    _headers.addAll(headers);
    return this;
  }

  RequestBuilder withHttpMethod(HttpMethod method) {
    _httpMethod = method;
    return this;
  }

  RequestBuilder withResponseValidationOverride(bool Function(Map<String, dynamic>) responseDelegate) {
    _responseValidationDelegate = responseDelegate;
    return this;
  }

  RequestBuilder withCancellationToken(CancelToken token) {
    _cancelToken = token;
    return this;
  }

  RequestBuilder withSearchQuery(String query) {
    _searchQuery = query;
    return this;
  }

  RequestBuilder setEmbeded(bool value) {
    _emdeded = value;
    return this;
  }

  RequestBuilder withPerPage(int count) {
    _perPageCount = count;
    return this;
  }

  RequestBuilder withPageNumber(int pageNumber) {
    _pageNumber = pageNumber;
    return this;
  }

  RequestBuilder withValuesBefore(DateTime dateTime) {
    _before = dateTime;
    return this;
  }

  RequestBuilder withValuesAfter(DateTime dateTime) {
    _after = dateTime;
    return this;
  }

  RequestBuilder withValuesBetween(DateTime start, DateTime end) {
    _before = start;
    _after = end;
    return this;
  }

  RequestBuilder allowAuthors(Iterable<int> ids) {
    _allowedAuthors ??= [];
    _allowedAuthors.addAll(ids);
    return this;
  }

  RequestBuilder excludeAuthors(Iterable<int> ids) {
    _excludedAuthors ??= [];
    _excludedAuthors.addAll(ids);
    return this;
  }

  RequestBuilder includeIds(Iterable<int> ids) {
    _allowedIds ??= [];
    _allowedIds.addAll(ids);
    return this;
  }

  RequestBuilder excludeIds(Iterable<int> ids) {
    _excludedIds ??= [];
    _excludedIds.addAll(ids);
    return this;
  }

  RequestBuilder withResultOffset(int offset) {
    _resultOffset = offset;
    return this;
  }

  RequestBuilder allowSlugs(Iterable<String> slugs) {
    _limitBySlug ??= [];
    _limitBySlug.addAll(slugs);
    return this;
  }

  RequestBuilder orderResultsBy(FilterOrder order) {
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

  RequestBuilder sortResultsBy(FilterSortOrder sortOrder) {
    var url = _baseUri.toString();
    url = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final endPoint = _baseUri.toString().substring(url.lastIndexOf('/'));

    if (sortOrder == FilterSortOrder.DATE && endPoint.toLowerCase() == 'users') {
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
        if (endPoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.URL:
        if (endPoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.NAME:
        if (endPoint.toLowerCase() == 'users') {
          _sortOrder = sortOrder.toString().split('.').last.toLowerCase();
        }
        break;
      case FilterSortOrder.INCLUDESLUGS:
        _sortOrder = 'include_slugs';
        break;
    }

    return this;
  }

  RequestBuilder withScope(FilterScope scope) {
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

  RequestBuilder limitToSticky(bool shouldLimit) {
    _onlySticky = shouldLimit;
    return this;
  }

  RequestBuilder allowTags(Iterable<int> tags) {
    _allowedTags ??= [];
    _allowedTags.addAll(tags);
    return this;
  }

  RequestBuilder excludeTags(Iterable<int> tags) {
    _excludedTags ??= [];
    _excludedTags.addAll(tags);
    return this;
  }

  RequestBuilder allowCategories(Iterable<int> categories) {
    _allowedCategories ??= [];
    _allowedCategories.addAll(categories);
    return this;
  }

  RequestBuilder excludeCategories(Iterable<int> categories) {
    _excludedCategories ??= [];
    _excludedCategories.addAll(categories);
    return this;
  }

  RequestBuilder setAllowedTaxonomyRelation(TaxonomyRelation relation) {
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

  RequestBuilder setAllowedStatus(PostAvailabilityStatus status) {
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

  @override
  Request build() {
    if (_createUri()) {
      return Request(
        _requestUri,
        endpoint: _endpoint,
        callback: null,
        validationDelegate: _responseValidationDelegate,
        cancelToken: _cancelToken,
        httpMethod: _httpMethod,
        formBody: _formBody,
        authorization: _authorization,
        headers: _headers,
      );
    }

    return null;
  }

  Request buildWithCallback(Callback callback) {
    if (_createUri()) {
      return Request(
        _requestUri,
        endpoint: _endpoint,
        callback: callback,
        validationDelegate: _responseValidationDelegate,
        cancelToken: _cancelToken,
        httpMethod: _httpMethod,
        formBody: _formBody,
        authorization: _authorization,
        headers: _headers,
      );
    }

    return null;
  }

  @override
  RequestBuilder initializeWithDefaultValues() => this;
}
