import 'package:dio/dio.dart';
import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/request_builder_base.dart';

import 'request.dart';
import 'response_container.dart';

class RequestBuilder implements IRequestBuilder<RequestBuilder, Request> {
  RequestBuilder.withValues(String requestUrlBase, String endpoint) {
    if (requestUrlBase == null || endpoint == null) {
      throw ArgumentError('Invalid parameters.');
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

  static RequestBuilder withBuilder() => RequestBuilder();

  RequestBuilder();

  Uri _baseUri;
  Uri _requestUri;
  CancelToken _cancelToken;
  String _endpoint;
  String _context;
  int _pageNumber;
  int _perPageCount;
  String _searchQuery;
  DateTime _after;
  DateTime _before;
  List<int> _allowedAuthors;
  List<int> _excludedAuthors;
  List<int> _excludedIds;
  List<int> _allowedIds;
  int _resultOffset;
  String _resultOrder;
  String _sortOrder;
  List<String> _limitBySlug;
  String _limitByStatus;
  String _limitByTaxonomyReleation;
  List<int> _allowedTags;
  List<int> _excludedTags;
  List<int> _allowedCategories;
  List<int> _excludedCategories;
  bool _onlySticky;
  bool _emdeded;
  // Authoriation
  bool Function(String) _responseValidationDelegate;
  HttpMethod _httpMethod;
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

  bool _createUri(){
    // TODO
  }

  

  @override
  Request build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  RequestBuilder initializeWithDefaultValues() {
    // TODO: implement initializeWithDefaultValues
    throw UnimplementedError();
  }
}
