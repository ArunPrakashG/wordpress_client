import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/comment_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class CommentCreateBuilder
    implements IQueryBuilder<CommentCreateBuilder, Comment> {
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

  int? _author;
  String? _authorIp;
  String? _authorUrl;
  String? _authorEmail;
  String? _authorDisplayName;
  String? _authorUserAgent;
  int? _commentParent;
  String? _content;
  int? _postId;

  CommentCreateBuilder withAuthor(int id) {
    _author = id;
    return this;
  }

  CommentCreateBuilder withAuthorIp(String ip) {
    _authorIp = ip;
    return this;
  }

  CommentCreateBuilder withAuthorUrl(String url) {
    _authorUrl = url;
    return this;
  }

  CommentCreateBuilder withAuthorEmail(String email) {
    _authorEmail = email;
    return this;
  }

  CommentCreateBuilder withAuthorDisplayName(String displayName) {
    _authorDisplayName = displayName;
    return this;
  }

  CommentCreateBuilder withAuthorUserAgent(String userAgent) {
    _authorUserAgent = userAgent;
    return this;
  }

  CommentCreateBuilder withCommentParent(int parent) {
    _commentParent = parent;
    return this;
  }

  CommentCreateBuilder withContent(String content) {
    _content = content;
    return this;
  }

  CommentCreateBuilder withPostId(int id) {
    _postId = id;
    return this;
  }

  @override
  Request<Comment> build() {
    return Request<Comment>(
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
      if (_author != null) 'author': _author,
      if (!isNullOrEmpty(_authorIp)) 'author_ip': _authorIp,
      if (!isNullOrEmpty(_authorUrl)) 'author_url': _authorUrl,
      if (!isNullOrEmpty(_authorEmail)) 'author_email': _authorEmail,
      if (!isNullOrEmpty(_authorDisplayName))
        'author_display_name': _authorDisplayName,
      if (!isNullOrEmpty(_authorUserAgent))
        'author_user_agent': _authorUserAgent,
      if (_commentParent != null) 'parent': _commentParent,
      if (!isNullOrEmpty(_content)) 'content': _content,
      if (_postId != null) 'post': _postId,
    };
  }

  @override
  CommentCreateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  CommentCreateBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  CommentCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  CommentCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  CommentCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  CommentCreateBuilder withHeaders(
      Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  CommentCreateBuilder withQueryParameters(
      Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  CommentCreateBuilder withResponseValidationOverride(
      bool Function(Comment) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
