import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';

import '../../authorization/authorization_base.dart';
import '../../enums.dart';
import '../../responses/post_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class PostUpdateBuilder implements IQueryBuilder<PostUpdateBuilder, Post> {
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
  bool Function(Post)? responseValidationDelegate;

  String? _slug;
  String? _title;
  String? _content;
  String? _excerpt;
  String? _password;
  String? _status;
  int? _authorId;
  int? _featuredMediaId;
  String? _commentStatus;
  String? _pingStatus;
  String? _format;
  bool? _asSticky = false;
  List<int>? _categories;
  List<int>? _tags;

  PostUpdateBuilder withId(int? id) {
    endpoint = '$endpoint/$id';
    return this;
  }

  PostUpdateBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  PostUpdateBuilder withContent(String content) {
    _content = content;
    return this;
  }

  PostUpdateBuilder withExcerpt(String excerpt) {
    _excerpt = excerpt;
    return this;
  }

  PostUpdateBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  PostUpdateBuilder withStatus(ContentStatus status) {
    _status = status.toString().split('.').last.toLowerCase();
    return this;
  }

  PostUpdateBuilder withAuthor(int author) {
    _authorId = author;
    return this;
  }

  PostUpdateBuilder withFeaturedMedia(int featuredMedia) {
    _featuredMediaId = featuredMedia;
    return this;
  }

  PostUpdateBuilder withCommentStatus(Status commentStatus) {
    _commentStatus = commentStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  PostUpdateBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus.toString().split('.').last.toLowerCase();
    return this;
  }

  PostUpdateBuilder withFormat(PostFormat format) {
    _format = format.toString().split('.').last.toLowerCase();
    return this;
  }

  PostUpdateBuilder withAsSticky(bool asSticky) {
    _asSticky = asSticky;
    return this;
  }

  PostUpdateBuilder withCategories(Iterable<int> categories) {
    _categories ??= [];
    _categories!.addAll(categories);
    return this;
  }

  PostUpdateBuilder withTags(Iterable<int> tags) {
    _tags ??= [];
    _tags!.addAll(tags);
    return this;
  }

  PostUpdateBuilder withSlug(String slug) {
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
      formBody: FormData.fromMap(_parseParameters()),
    );
  }

  Map<String, dynamic> _parseParameters() {
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
      if (_asSticky != null && _asSticky!) 'sticky': '1',
      if (_categories != null && _categories!.isNotEmpty) 'categories': _categories!.join(','),
      if (_tags != null && _tags!.isNotEmpty) 'tags': _tags!.join(','),
      if (!isNullOrEmpty(_slug)) 'slug': _slug,
    };
  }

  @override
  PostUpdateBuilder initializeWithDefaultValues() {
    return this;
  }

  @override
  PostUpdateBuilder withAuthorization(IAuthorization auth) {
    authorization = auth;
    return this;
  }

  @override
  PostUpdateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  PostUpdateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  PostUpdateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  PostUpdateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers!.addAll(customHeaders);
    return this;
  }

  @override
  PostUpdateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters!.addAll(extraQueryParameters);
    return this;
  }

  @override
  PostUpdateBuilder withResponseValidationOverride(bool Function(Post) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
