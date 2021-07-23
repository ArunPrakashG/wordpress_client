import 'package:wordpress_client/src/builders/request.dart';
import 'package:wordpress_client/src/authorization.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:wordpress_client/src/responses/category_response.dart';
import 'package:wordpress_client/src/utilities/pair.dart';
import 'package:wordpress_client/src/utilities/callback.dart';

import '../request_builder_base.dart';

class CategoryCreateBuilder implements IQueryBuilder<CategoryCreateBuilder, Category>{
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
  bool Function(Category p1) responseValidationDelegate;

  @override
  Request<Category> build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder initializeWithDefaultValues() {
    // TODO: implement initializeWithDefaultValues
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withAuthorization(Authorization auth) {
    // TODO: implement withAuthorization
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withCallback(Callback requestCallback) {
    // TODO: implement withCallback
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withCancellationToken(CancelToken token) {
    // TODO: implement withCancellationToken
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withEndpoint(String newEndpoint) {
    // TODO: implement withEndpoint
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    // TODO: implement withHeaders
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    // TODO: implement withQueryParameters
    throw UnimplementedError();
  }

  @override
  CategoryCreateBuilder withResponseValidationOverride(bool Function(Category p1) responseDelegate) {
    // TODO: implement withResponseValidationOverride
    throw UnimplementedError();
  }

}