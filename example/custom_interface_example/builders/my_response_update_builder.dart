import 'package:wordpress_client/wordpress_client.dart';

import '../respones/my_response.dart';

class MyResponseUpdateBuilder implements IQueryBuilder<MyResponseUpdateBuilder, MyResponse> {
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
  MyResponseUpdateBuilder initializeWithDefaultValues() {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withAuthorization(IAuthorization auth) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withCallback(Callback requestCallback) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withCancellationToken(CancelToken token) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withEndpoint(String newEndpoint) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    throw UnimplementedError();
  }

  @override
  MyResponseUpdateBuilder withResponseValidationOverride(bool Function(MyResponse p1) responseDelegate) {
    throw UnimplementedError();
  }
}
