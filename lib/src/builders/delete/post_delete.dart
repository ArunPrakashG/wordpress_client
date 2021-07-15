import 'package:dio/src/cancel_token.dart';

import '../../enums.dart';
import '../../requests/builders/request_builder_base.dart';
import '../../requests/request.dart';
import '../../utilities/pair.dart';
import '../../wordpress_authorization.dart';

class PostDeleteBuilder implements IRequestBuilder<PostDeleteBuilder, Request> {
  @override
  WordpressAuthorization authorization;

  @override
  CancelToken cancelToken;

  @override
  String endpoint;

  @override
  List<Pair<String, String>> headers;

  @override
  List<Pair<String, String>> queryParameters;

  @override
  bool Function(Map<String, dynamic> p1) responseValidationDelegate;

  int _id;
  bool _force = false;

  PostDeleteBuilder withId(int id) {
    _id = id;
    endpoint += '/$_id';
    return this;
  }

  PostDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  @override
  Request build() {
    return new Request(
      endpoint,
      queryParams: _parseQueryParameters(),
      callback: null,
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
      'id': _id.toString(),
      if (_force) 'force': 'true',
    };
  }

  @override
  PostDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  PostDeleteBuilder withAuthorization(WordpressAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  PostDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  PostDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  PostDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  PostDeleteBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  PostDeleteBuilder withResponseValidationOverride(bool Function(Map<String, dynamic> p1) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
