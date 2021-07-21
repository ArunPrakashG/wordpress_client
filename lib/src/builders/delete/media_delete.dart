import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/media_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MediaDeleteBuilder implements IQueryBuilder<MediaDeleteBuilder, Media> {
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
  bool Function(Media) responseValidationDelegate;

  int _id = -1;
  bool _force = false;

  MediaDeleteBuilder withId(int id) {
    _id = id;
    endpoint += '/$_id';
    return this;
  }

  MediaDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  @override
  Request<Media> build() {
    return new Request<Media>(
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
  MediaDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  MediaDeleteBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MediaDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MediaDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MediaDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  MediaDeleteBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  MediaDeleteBuilder withResponseValidationOverride(bool Function(Media) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  MediaDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
