import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../responses/media_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MediaUpdateBuilder implements IQueryBuilder<MediaUpdateBuilder, Media> {
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
  bool Function(Media)? responseValidationDelegate;

  String? _slug;
  String? _status;
  String? _title;
  int? _author;
  String? _commentStatus;
  String? _pingStatus;
  String? _altText;
  String? _caption;
  String? _description;
  int? _postId;

  @override
  Request<Media> build() {
    return Request<Media>(
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
      if (!isNullOrEmpty(_status)) 'status': _status,
      if (!isNullOrEmpty(_title)) 'title': _title,
      if (_author != null && _author != 0) 'author': _author,
      if (!isNullOrEmpty(_commentStatus)) 'comment_status': _commentStatus,
      if (!isNullOrEmpty(_pingStatus)) 'ping_status': _pingStatus,
      if (!isNullOrEmpty(_altText)) 'alt_text': _altText,
      if (!isNullOrEmpty(_caption)) 'caption': _caption,
      if (!isNullOrEmpty(_description)) 'description': _description,
      if (_postId != null && _postId != 0) 'post': _postId,
    };
  }

  MediaUpdateBuilder withId(int id) {
    endpoint = '/$id';
    return this;
  }

  MediaUpdateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  MediaUpdateBuilder withStatus(ContentStatus status) {
    _status = status.toString().split('.').last.toLowerCase();
    return this;
  }

  MediaUpdateBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  MediaUpdateBuilder withAuthor(int author) {
    _author = author;
    return this;
  }

  MediaUpdateBuilder withCommentStatus(Status commentStatus) {
    _commentStatus = commentStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  MediaUpdateBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  MediaUpdateBuilder withAltText(String altText) {
    _altText = altText;
    return this;
  }

  MediaUpdateBuilder withCaption(String caption) {
    _caption = caption;
    return this;
  }

  MediaUpdateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  MediaUpdateBuilder withPostId(int postId) {
    _postId = postId;
    return this;
  }

  @override
  MediaUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  MediaUpdateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MediaUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MediaUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MediaUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MediaUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  MediaUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  MediaUpdateBuilder withResponseValidationOverride(bool Function(Media) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
