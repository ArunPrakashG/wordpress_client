import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class UserDeleteBuilder implements IRequestBuilder<UserDeleteBuilder, User> {
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
  bool Function(User) responseValidationDelegate;

  @override
  Callback callback;

  int _id = -1;
  bool _force = false;
  int _reassign = -1;

  UserDeleteBuilder withId(int id) {
    _id = id;
    endpoint += '/$_id';
    return this;
  }

  UserDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  UserDeleteBuilder withReassign(int newUserId) {
    _reassign = newUserId;
    return this;
  }

  @override
  Request<User> build() {
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
      'id': _id.toString(),
      if (_force) 'force': 'true',
      if (_reassign > 0) 'reassign': _reassign.toString(),
    };
  }

  @override
  UserDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  UserDeleteBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  UserDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  UserDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  UserDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers = [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  UserDeleteBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserDeleteBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  UserDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
