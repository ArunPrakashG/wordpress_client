import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/post_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class PostDeleteBuilder implements IQueryBuilder<PostDeleteBuilder, Post> {
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
  bool Function(Post) responseValidationDelegate;

  @override
  Callback callback;

  int _id = -1;
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
  Request<Post> build() {
    return new Request<Post>(
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
      'id': _id.toString(),
      if (_force) 'force': 'true',
    };
  }

  @override
  PostDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  PostDeleteBuilder withAuthorization(Authorization auth) {
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
  PostDeleteBuilder withResponseValidationOverride(bool Function(Post) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  PostDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
