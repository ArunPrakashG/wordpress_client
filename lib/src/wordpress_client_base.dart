import 'package:wordpress_client/src/builders/retrive/post_retrive.dart';
import 'package:wordpress_client/src/exceptions/bootstrap_failed_exception.dart';
import 'package:wordpress_client/src/exceptions/client_not_initialized_exception.dart';
import 'package:wordpress_client/src/utilities/helpers.dart';

import 'exceptions/null_reference_exception.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'internal_requester.dart';
import 'builders/list/post_list.dart';
import 'requests/request.dart';
import 'responses/post_response.dart';
import 'responses/response_container.dart';
import 'utilities/cookie_container.dart';

const int defaultRequestTimeout = 60;

class WordpressClient {
  Map<String, dynamic> _interfaces;
  InternalRequester _requester;

  WordpressClient(String baseUrl, String path, {CookieContainer cookieContainer}) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    _requester = InternalRequester(baseUrl, path, cookieContainer: cookieContainer ?? CookieContainer());
    _initializeInterfaces();
  }

  void _initializeInterfaces() {
    _interfaces ??= new Map<String, dynamic>();
    _interfaces['posts'] = PostsInterface<Post>();
    //_interfaces['media'] = MediaInterface<Media>();
  }

  WordpressClient bootstrap(InternalRequester Function(InternalRequester) requesterConfiguration) {
    _requester = requesterConfiguration(_requester);

    if (_requester == null) {
      throw BootstrapFailedException('Bootstrap configuration failed.');
    }

    return this;
  }

  T getInterfaceByName<T>(String name) {
    if (isNullOrEmpty(name)) {
      throw NullReferenceException('Interface name is invalid.');
    }

    return _interfaces[name];
  }

  T getInterfaceByType<T>() {
    if (_interfaces == null || _interfaces.isEmpty) {
      throw ClientNotInitializedException('Please correctly initialize WordpressClient before retriving the available interfaces.');
    }

    return _interfaces.entries.singleWhere((i) => i.value is T).value;
  }

  Future<ResponseContainer<List<Post>>> listPosts(Request Function(PostListBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').list<Post>(
      request: builder(PostListBuilder.withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post>> retrivePost(Request Function(PostRetriveBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').retrive<Post>(
      request: builder(PostRetriveBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

/*
  Future<ResponseContainer<List<Post>>> fetchPosts(Request Function(RequestBuilder) builder) async {
    final response = await _postRequestAsync<dynamic>(
        builder(RequestBuilder().initializeWithDefaultValues().withBaseAndEndpoint(parseUrl(_baseUrl, _path), 'posts')));

    return ResponseContainer(
      List<Post>.from((response.value as Iterable<dynamic>).map<Post>((e) => Post.fromMap(e))),
      responseCode: response.responseCode,
      status: response.status,
      responseHeaders: response.responseHeaders,
      duration: response.duration,
      exception: response.exception,
      errorMessage: response.errorMessage,
    );
  }
*/
}
