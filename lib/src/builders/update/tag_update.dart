import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/tag_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class TagUpdateBuilder implements IQueryBuilder<TagUpdateBuilder, Tag> {
  @override
  Authorization? authorization;

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
  bool Function(Tag)? responseValidationDelegate;

  String? _description;
  String? _name;
  String? _slug;

  TagUpdateBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  TagUpdateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  TagUpdateBuilder withName(String name) {
    _name = name;
    return this;
  }

  TagUpdateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  @override
  Request<Tag> build() {
    return Request<Tag>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: FormData.fromMap(_parseParameters()),
    );
  }

  Map<String, dynamic> _parseParameters() {
    return {
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
      if (!isNullOrEmpty(_name)) 'name': _name,
      if (!isNullOrEmpty(_description)) 'description': _description,
    };
  }

  @override
  TagUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  TagUpdateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  TagUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  TagUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  TagUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  TagUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  TagUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  TagUpdateBuilder withResponseValidationOverride(bool Function(Tag) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
