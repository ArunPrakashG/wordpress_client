import 'package:dio/src/cancel_token.dart';
import 'package:wordpress_client/src/authorization/authorization_base.dart';

import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MeDeleteBuilder implements IQueryBuilder<MeDeleteBuilder, User> {
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
  bool Function(User)? responseValidationDelegate;

  bool _force = false;
  int _reassign = -1;

  MeDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  MeDeleteBuilder withReassign(int newUserId) {
    _reassign = newUserId;
    return this;
  }

  @override
  Request<User> build() {
    endpoint = '$endpoint/me';
    return new Request<User>(
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
      if (_force) 'force': 'true',
      if (_reassign > 0) 'reassign': _reassign.toString(),
    };
  }

  @override
  MeDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  MeDeleteBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MeDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MeDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MeDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MeDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  MeDeleteBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  MeDeleteBuilder withResponseValidationOverride(
      bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
