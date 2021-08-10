import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/category_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CategoryCreateBuilder implements IQueryBuilder<CategoryCreateBuilder, Category> {
  @override
  Authorization? authorization;

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

  String? _description;
  String? _name;
  String? _slug;
  int _parent = 0;

  CategoryCreateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  CategoryCreateBuilder withName(String name) {
    _name = name;
    return this;
  }

  CategoryCreateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  CategoryCreateBuilder withParent(int parent) {
    _parent = parent;
    return this;
  }

  @override
  Request<Category> build() {
    return Request<Category>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: FormData.fromMap(_parseParameters()),
    );
  }

  Map<String, dynamic> _parseParameters() {
    return {
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
      if (!isNullOrEmpty(_name)) 'name': _name,
      if (!isNullOrEmpty(_description)) 'description': _description,
      if (_parent != 0) 'parent': _parent,
    };
  }

  @override
  CategoryCreateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CategoryCreateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CategoryCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  CategoryCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CategoryCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CategoryCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CategoryCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CategoryCreateBuilder withResponseValidationOverride(bool Function(Category) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
