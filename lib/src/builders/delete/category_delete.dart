import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/category_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CategoryDeleteBuilder implements IQueryBuilder<CategoryDeleteBuilder, Category>{
  @override
  Authorization authorization;

  @override
  CancelToken cancelToken;

  @override
  String endpoint;

  @override
  List<Pair<String, String>> headers;

  @override
  List<Pair<String, String>> queryParameters;

  @override
  bool Function(Category) responseValidationDelegate;

  @override
  Callback callback;

  bool _force = false;

  CategoryDeleteBuilder withId(int id) {
    endpoint += '/$id';
    return this;
  }

  CategoryDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  @override
  Request<Category> build() {
    return new Request<Category>(
      endpoint,
      queryParams: _parseQueryParameters(),
      callback: callback,
      headers: headers,
      formBody: null,
      authorization: authorization,
      cancelToken: cancelToken,
      validationDelegate: responseValidationDelegate,
      httpMethod: HttpMethod.DELETE,
    );
  }

  Map<String, String> _parseQueryParameters() {
    return {
      if (_force) 'force': 'true',
    };
  }

  @override
  CategoryDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CategoryDeleteBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CategoryDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CategoryDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CategoryDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers = [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  CategoryDeleteBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  CategoryDeleteBuilder withResponseValidationOverride(bool Function(Category) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  CategoryDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}