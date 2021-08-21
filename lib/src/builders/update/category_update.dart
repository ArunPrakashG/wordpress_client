import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/category_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CategoryUpdateBuilder
    implements IQueryBuilder<CategoryUpdateBuilder, Category> {
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

  String? _description;
  String? _name;
  String? _slug;
  int _parent = 0;

  CategoryUpdateBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  CategoryUpdateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  CategoryUpdateBuilder withName(String name) {
    _name = name;
    return this;
  }

  CategoryUpdateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  CategoryUpdateBuilder withParent(int parent) {
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
  CategoryUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CategoryUpdateBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CategoryUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  CategoryUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CategoryUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CategoryUpdateBuilder withHeaders(
      Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CategoryUpdateBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CategoryUpdateBuilder withResponseValidationOverride(
      bool Function(Category) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
