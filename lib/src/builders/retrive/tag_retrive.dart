import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/tag_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class TagRetriveBuilder implements IQueryBuilder<TagRetriveBuilder, Tag> {
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
  bool Function(Tag) responseValidationDelegate;

  String _context;

  TagRetriveBuilder withId(int id) {
    endpoint += '/$id';
    return this;
  }

  TagRetriveBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  @override
  Request<Tag> build() {
    return Request<Tag>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.GET,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      queryParams: _parseQueryParameters(),
    );
  }

  Map<String, String> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
    };
  }

  @override
  TagRetriveBuilder initializeWithDefaultValues() => this;

  @override
  TagRetriveBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  TagRetriveBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  TagRetriveBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  TagRetriveBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  TagRetriveBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  TagRetriveBuilder withResponseValidationOverride(bool Function(Tag) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  TagRetriveBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
