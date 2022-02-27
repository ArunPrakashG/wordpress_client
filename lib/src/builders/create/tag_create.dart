import 'package:dio/dio.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/tag_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class TagCreateBuilder implements IQueryBuilder<TagCreateBuilder, Tag> {
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
  bool Function(Tag)? responseValidationDelegate;

  String? _description;
  String? _name;
  String? _slug;

  TagCreateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  TagCreateBuilder withName(String name) {
    _name = name;
    return this;
  }

  TagCreateBuilder withSlug(String slug) {
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
  TagCreateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  TagCreateBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  TagCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  TagCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  TagCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  TagCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  TagCreateBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  TagCreateBuilder withResponseValidationOverride(
      bool Function(Tag) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
