import 'package:wordpress_client/wordpress_client.dart';

import '../respones/my_response.dart';

class MyResponseRetriveBuilder implements IQueryBuilder<MyResponseRetriveBuilder, MyResponse> {
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
  MyResponseRetriveBuilder initializeWithDefaultValues() {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withAuthorization(IAuthorization auth) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withCallback(Callback requestCallback) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withCancellationToken(CancelToken token) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withEndpoint(String newEndpoint) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    throw UnimplementedError();
  }

  @override
  MyResponseRetriveBuilder withResponseValidationOverride(bool Function(MyResponse p1) responseDelegate) {
    throw UnimplementedError();
  }
}
