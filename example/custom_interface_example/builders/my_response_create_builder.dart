import 'package:wordpress_client/wordpress_client.dart';

import '../respones/my_response.dart';

class MyResponseCreateBuilder implements IQueryBuilder<MyResponseCreateBuilder, MyResponse> {
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
  MyResponseCreateBuilder initializeWithDefaultValues() {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withAuthorization(IAuthorization auth) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withCallback(Callback requestCallback) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withCancellationToken(CancelToken token) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withEndpoint(String newEndpoint) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    throw UnimplementedError();
  }

  @override
  MyResponseCreateBuilder withResponseValidationOverride(bool Function(MyResponse p1) responseDelegate) {
    throw UnimplementedError();
  }
}
