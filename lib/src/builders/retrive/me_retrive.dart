import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/user_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MeRetriveBuilder implements IRequestBuilder<MeRetriveBuilder, User> {
  @override
  Authorization authorization;

  @override
  Callback callback;

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

  String _context = 'view';

  MeRetriveBuilder withContext(FilterScope context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  @override
  Request<User> build() {
    endpoint += '/me';
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

  Map<String, String> _parseQueryParameters() {
    return {
      'context': _context,
    };
  }

  @override
  MeRetriveBuilder initializeWithDefaultValues() => this;

  @override
  MeRetriveBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MeRetriveBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MeRetriveBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MeRetriveBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MeRetriveBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  MeRetriveBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  MeRetriveBuilder withResponseValidationOverride(bool Function(User) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
