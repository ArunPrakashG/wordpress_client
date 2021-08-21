import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/comment_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CommentRetriveBuilder
    implements IQueryBuilder<CommentRetriveBuilder, Comment> {
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
  bool Function(Comment)? responseValidationDelegate;

  String? _context;
  String? _password;

  CommentRetriveBuilder withId(int id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  CommentRetriveBuilder withContext(FilterContext context) {
    _context = context.toString().split('.').last.toLowerCase();
    return this;
  }

  CommentRetriveBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  @override
  Request<Comment> build() {
    return Request<Comment>(
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

  Map<String, String?> _parseQueryParameters() {
    return {
      if (!isNullOrEmpty(_context)) 'context': _context,
      if (!isNullOrEmpty(_password)) 'password': _password,
    };
  }

  @override
  CommentRetriveBuilder initializeWithDefaultValues() => this;

  @override
  CommentRetriveBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CommentRetriveBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CommentRetriveBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CommentRetriveBuilder withHeaders(
      Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CommentRetriveBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CommentRetriveBuilder withResponseValidationOverride(
      bool Function(Comment) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }

  @override
  CommentRetriveBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }
}
