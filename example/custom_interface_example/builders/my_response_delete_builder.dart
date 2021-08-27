import 'package:wordpress_client/wordpress_client.dart';

import '../respones/my_response.dart';

class MyResponseDeleteBuilder implements IQueryBuilder<MyResponseDeleteBuilder, MyResponse> {
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
  bool Function(MyResponse p1)? responseValidationDelegate;

  @override
  Request<MyResponse> build() {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder initializeWithDefaultValues() {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withAuthorization(IAuthorization auth) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withCallback(Callback requestCallback) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withCancellationToken(CancelToken token) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withEndpoint(String newEndpoint) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    throw UnimplementedError();
  }

  @override
  MyResponseDeleteBuilder withResponseValidationOverride(bool Function(MyResponse p1) responseDelegate) {
    throw UnimplementedError();
  }
}
