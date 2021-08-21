import 'package:dio/src/cancel_token.dart';
import 'package:wordpress_client/src/authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/tag_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class TagDeleteBuilder implements IQueryBuilder<TagDeleteBuilder, Tag> {
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
  bool Function(Tag)? responseValidationDelegate;

  @override
  Callback? callback;

  bool _force = false;

  TagDeleteBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  TagDeleteBuilder withForce(bool force) {
    _force = force;
    return this;
  }

  @override
  Request<Tag> build() {
    return new Request<Tag>(
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
    };
  }

  @override
  TagDeleteBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  TagDeleteBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  TagDeleteBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  TagDeleteBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  TagDeleteBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers = [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  TagDeleteBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  TagDeleteBuilder withResponseValidationOverride(
      bool Function(Tag) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  TagDeleteBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
