import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/comment_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CommentDeleteBuilder
    implements IQueryBuilder<CommentDeleteBuilder, Comment> {
  @override
  IAuthorization? authorization;

  @override
  CancelToken? cancelToken;

  @override
  String? endpoint;

  @override
  List<Pair<String, String>>? headers;

  @override
  List<Pair<String, String>>? queryParameters;

  @override
  bool Function(Comment)? responseValidationDelegate;

  @override
  Callback? callback;

  bool _force = false;
  String? _password;

  CommentDeleteBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  CommentDeleteBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  CommentDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  @override
  Request<Comment> build() {
    return new Request<Comment>(
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

  Map<String, String?> _parseQueryParameters() {
    return {
      if (_force) 'force': 'true',
      if (!isNullOrEmpty(_password)) 'password': _password,
    };
  }

  @override
  CommentDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CommentDeleteBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CommentDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CommentDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CommentDeleteBuilder withHeaders(
      Iterable<Pair<String, String>> customHeaders) {
    headers = [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CommentDeleteBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CommentDeleteBuilder withResponseValidationOverride(
      bool Function(Comment) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  CommentDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
