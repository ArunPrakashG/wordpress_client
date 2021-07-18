import 'package:dio/src/cancel_token.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../request_builder_base.dart';
import '../request.dart';
import '../../responses/post_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';

class PostCreateBuilder implements IRequestBuilder<PostCreateBuilder, Post> {
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
  bool Function(Post) responseValidationDelegate;

  String _slug;
  String _title;
  String _content;
  String _excerpt;
  String _password;
  String _status;
  int _authorId;
  int _featuredMediaId;
  String _commentStatus;
  String _pingStatus;
  String _format;
  bool _asSticky;
  List<int> _categories;
  List<int> _tags;

  PostCreateBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  PostCreateBuilder withContent(String content) {
    _content = content;
    return this;
  }

  PostCreateBuilder withExcerpt(String excerpt) {
    _excerpt = excerpt;
    return this;
  }

  PostCreateBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  PostCreateBuilder withStatus(ContentStatus status) {
    _status = status.toString().split('.').last.toLowerCase();
    return this;
  }

  PostCreateBuilder withAuthor(int author) {
    _authorId = author;
    return this;
  }

  PostCreateBuilder withFeaturedMedia(int featuredMedia) {
    _featuredMediaId = featuredMedia;
    return this;
  }

  PostCreateBuilder withCommentStatus(Status commentStatus) {
    _commentStatus = commentStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  PostCreateBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  PostCreateBuilder withFormat(PostFormat format) {
    _format = format.toString().split('.').last.toLowerCase();
    return this;
  }

  PostCreateBuilder withAsSticky(bool asSticky) {
    _asSticky = asSticky;
    return this;
  }

  PostCreateBuilder withCategories(Iterable<int> categories) {
    _categories ??= [];
    _categories.addAll(categories);
    return this;
  }

  PostCreateBuilder withTags(Iterable<int> tags) {
    _tags ??= [];
    _tags.addAll(tags);
    return this;
  }

  PostCreateBuilder withSlug(String slug) {
    _slug = slug;
    return this;
  }

  @override
  Request<Post> build() {
    return Request<Post>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: _parseParameters(),
    );
  }

  Map<String, String> _parseParameters() {
    return {
      if (!isNullOrEmpty(_title)) 'title': _title,
      if (!isNullOrEmpty(_content)) 'content': _content,
      if (!isNullOrEmpty(_excerpt)) 'excerpt': _excerpt,
      if (!isNullOrEmpty(_password)) 'password': _password,
      if (!isNullOrEmpty(_status)) 'status': _status,
      if (_authorId != 0) 'author': _authorId.toString(),
      if (_featuredMediaId != 0) 'featured_media': _featuredMediaId.toString(),
      if (!isNullOrEmpty(_commentStatus)) 'comment_status': _commentStatus,
      if (!isNullOrEmpty(_pingStatus)) 'ping_status': _pingStatus,
      if (!isNullOrEmpty(_format)) 'format': _format,
      if (_asSticky) 'sticky': '1',
      if (_categories != null && _categories.isNotEmpty) 'categories': _categories.join(','),
      if (_tags != null && _tags.isNotEmpty) 'tags': _tags.join(','),
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
    };
  }

  @override
  PostCreateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  PostCreateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  PostCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  PostCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  PostCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  PostCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  PostCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  PostCreateBuilder withResponseValidationOverride(bool Function(Post) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
