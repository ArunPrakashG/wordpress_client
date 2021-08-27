import 'package:wordpress_client/wordpress_client.dart';

import '../respones/my_response.dart';

class MyResponseListBuilder implements IQueryBuilder<MyResponseListBuilder, List<MyResponse>> {
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
  bool Function(List<MyResponse> p1)? responseValidationDelegate;

  @override
  Request<List<MyResponse>> build() {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder initializeWithDefaultValues() {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withAuthorization(IAuthorization auth) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withCallback(Callback requestCallback) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withCancellationToken(CancelToken token) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withEndpoint(String newEndpoint) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    throw UnimplementedError();
  }

  @override
  MyResponseListBuilder withResponseValidationOverride(bool Function(List<MyResponse> p1) responseDelegate) {
    throw UnimplementedError();
  }
}
