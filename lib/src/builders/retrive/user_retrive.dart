import 'package:dio/src/cancel_token.dart';
import 'package:wordpress_client/src/responses/user_response.dart';
import 'package:wordpress_client/src/utilities/callback.dart';

import '../../enums.dart';
import '../../requests/builders/request_builder_base.dart';
import '../../requests/request.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../../wordpress_authorization.dart';

class UserRetriveBuilder implements IRequestBuilder<UserRetriveBuilder, User> {
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
  bool Function(User) responseValidationDelegate;

  @override
  Callback callback;

  int _id;
  String _context;

  UserRetriveBuilder withPostId(int id) {
    _id = id;
    endpoint += '/$_id';
    return this;
  }

  UserRetriveBuilder withContext(FilterScope context) {
    _context = context.toString().split('.').last.toLowerCase();
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
      httpMethod: HttpMethod.GET,
    );
  }

  Map<String, dynamic> _parseQueryParameters() {
    return {
      'id': _id,
      if (!isNullOrEmpty(_context)) 'context': _context,
    };
  }

  @override
  UserRetriveBuilder initializeWithDefaultValues() => this;

  @override
  UserRetriveBuilder withAuthorization(WordpressAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  UserRetriveBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  UserRetriveBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  UserRetriveBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  UserRetriveBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  UserRetriveBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  UserRetriveBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
