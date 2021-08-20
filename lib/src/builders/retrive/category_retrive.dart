import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/category_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CategoryRetriveBuilder implements IQueryBuilder<CategoryRetriveBuilder, Category> {
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
  bool Function(Category)? responseValidationDelegate;

  String? _context;

  CategoryRetriveBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  CategoryRetriveBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  @override
  Request<Category> build() {
    return Request<Category>(
      endpoint,
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
    };
  }

  @override
  CategoryRetriveBuilder initializeWithDefaultValues() => this;

  @override
  CategoryRetriveBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CategoryRetriveBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CategoryRetriveBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CategoryRetriveBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CategoryRetriveBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CategoryRetriveBuilder withResponseValidationOverride(bool Function(Category) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  CategoryRetriveBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
