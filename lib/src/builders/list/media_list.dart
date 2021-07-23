import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/media_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MediaListBuilder implements IQueryBuilder<MediaListBuilder, List<Media>> {
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
  bool Function(List<Media>) responseValidationDelegate;

  String _context;
  int _page = 1;
  int _perPage = 10;
  String _search;
  DateTime _after;
  DateTime _before;
  List<int> _allowedAuthors;
  List<int> _excludedAuthors;
  List<int> _excludedIds;
  List<int> _allowedIds;
  String _resultOrder;
  String _sortOrder;
  int _offset;
  List<int> _parentIds;
  List<int> _parentExclude;
  List<String> _slugs;
  String _status;
  String _mediaType;
  String _mimeType;

  @override
  Request<List<Media>> build() {
    return Request<List<Media>>(
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
      'page': _page.toString(),
      'per_page': _perPage.toString(),
      if (!isNullOrEmpty(_search)) 'search': _search,
      if (_after != null) 'after': _after.toString(),
      if (_before != null) 'before': _before.toString(),
      if (_allowedAuthors != null && _allowedAuthors.isNotEmpty) 'author': _allowedAuthors.join(','),
      if (_excludedAuthors != null && _excludedAuthors.isNotEmpty) 'author_exclude': _excludedAuthors.join(','),
      if (_excludedIds != null && _excludedIds.isNotEmpty) 'exclude': _excludedIds.join(','),
      if (_allowedIds != null && _allowedIds.isNotEmpty) 'include': _allowedIds.join(','),
      if (_offset != null && _offset > 0) 'offset': _offset.toString(),
      if (_parentIds != null && _parentIds.isNotEmpty) 'parent': _parentIds.join(','),
      if (_parentExclude != null && _parentExclude.isNotEmpty) 'parent_exclude': _parentExclude.join(','),
      if (_slugs != null && _slugs.isNotEmpty) 'slug': _slugs.join(','),
      if (!isNullOrEmpty(_status)) 'status': _status,
      if (!isNullOrEmpty(_mediaType)) 'media_type': _mediaType,
      if (!isNullOrEmpty(_mimeType)) 'mime_type': _mimeType,
      if (!isNullOrEmpty(_resultOrder)) 'order': _resultOrder,
      if (!isNullOrEmpty(_sortOrder)) 'orderby': _sortOrder,
      if (!isNullOrEmpty(_context)) 'context': _context,
    };
  }

  MediaListBuilder withStatus(MediaFilterStatus status) {
    _status = status.toString().split('.').last.toLowerCase();
    return this;
  }

  MediaListBuilder withSearchQuery(String search) {
    _search = search;
    return this;
  }

  MediaListBuilder withSlug(List<String> slugs) {
    _slugs ??= [];
    _slugs.addAll(slugs);
    return this;
  }

  MediaListBuilder allowParents(Iterable<int> ids) {
    _parentIds ??= [];
    _parentIds.addAll(ids);
    return this;
  }

  MediaListBuilder excludeParents(Iterable<int> ids) {
    _parentExclude ??= [];
    _parentExclude.addAll(ids);
    return this;
  }

  MediaListBuilder withPerPage(int count) {
    _perPage = count;
    return this;
  }

  MediaListBuilder withPageNumber(int pageNumber) {
    _page = pageNumber;
    return this;
  }

  MediaListBuilder withValuesBefore(DateTime dateTime) {
    _before = dateTime;
    return this;
  }

  MediaListBuilder withValuesAfter(DateTime dateTime) {
    _after = dateTime;
    return this;
  }

  MediaListBuilder withValuesBetween(DateTime start, DateTime end) {
    _before = start;
    _after = end;
    return this;
  }

  MediaListBuilder allowAuthors(Iterable<int> ids) {
    _allowedAuthors ??= [];
    _allowedAuthors.addAll(ids);
    return this;
  }

  MediaListBuilder excludeAuthors(Iterable<int> ids) {
    _excludedAuthors ??= [];
    _excludedAuthors.addAll(ids);
    return this;
  }

  MediaListBuilder includeIds(Iterable<int> ids) {
    _allowedIds ??= [];
    _allowedIds.addAll(ids);
    return this;
  }

  MediaListBuilder excludeIds(Iterable<int> ids) {
    _excludedIds ??= [];
    _excludedIds.addAll(ids);
    return this;
  }

  MediaListBuilder withResultOffset(int offset) {
    _offset = offset;
    return this;
  }

  MediaListBuilder withOnlyMediaType(FilterMediaType mediaType) {
    _mediaType = mediaType.toString().split('.').last.toLowerCase();
    return this;
  }

  MediaListBuilder withOnlyMimeType(String mimeType) {
    _mimeType = mimeType;
    return this;
  }

  MediaListBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  @override
  MediaListBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  MediaListBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MediaListBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MediaListBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MediaListBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MediaListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  MediaListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  MediaListBuilder withResponseValidationOverride(bool Function(List<Media>) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
