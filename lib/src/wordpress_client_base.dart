import 'builders/bootstrap_builder.dart';
import 'builders/create/post_create.dart';
import 'builders/delete/post_delete.dart';
import 'builders/delete/user_delete.dart';
import 'builders/list/post_list.dart';
import 'builders/list/user_list.dart';
import 'builders/retrive/post_retrive.dart';
import 'builders/retrive/user_retrive.dart';
import 'client_configuration.dart';
import 'exceptions/client_not_initialized_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'interface/posts.dart';
import 'interface/users.dart';
import 'internal_requester.dart';
import 'builders/request.dart';
import 'responses/post_response.dart';
import 'responses/response_container.dart';
import 'responses/user_response.dart';
import 'utilities/helpers.dart';

class WordpressClient {
  Map<String, dynamic> _interfaces;
  InternalRequester _requester;

  WordpressClient(String baseUrl, String path, {BootstrapConfiguration Function(BootstrapBuilder) bootstrapper}) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Endpoint is invalid.');
    }

    _requester = InternalRequester(baseUrl, path, bootstrapper(BootstrapBuilder()));
    _initializeInterfaces();
  }

  void _initializeInterfaces() {
    _interfaces ??= new Map<String, dynamic>();
    _interfaces['posts'] = PostsInterface<Post>();
    _interfaces['users'] = UsersInterface<User>();
    //_interfaces['media'] = MediaInterface<Media>();
  }

  T getInterfaceByName<T>(String name) {
    if (_interfaces == null || _interfaces.isEmpty) {
      throw ClientNotInitializedException('Please correctly initialize WordpressClient before retriving the available interfaces.');
    }

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

  Future<ResponseContainer<List<User>>> listUsers(Request Function(UserListBuilder) builder) async {
    return getInterfaceByName<UsersInterface<User>>('users').list<User>(
      resolver: User(),
      request: builder(UserListBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> retriveUser(Request Function(UserRetriveBuilder) builder) async {
    return getInterfaceByName<UsersInterface<User>>('users').retrive<User>(
      typeResolver: User(),
      request: builder(UserRetriveBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> deleteUser(Request Function(UserDeleteBuilder) builder) async {
    return getInterfaceByName<UsersInterface<User>>('users').retrive<User>(
      typeResolver: User(),
      request: builder(UserDeleteBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Post>>> listPosts(Request Function(PostListBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').list<Post>(
      resolver: Post(),
      request: builder(PostListBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post>> retrivePost(Request Function(PostRetriveBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').retrive<Post>(
      typeResolver: Post(),
      request: builder(PostRetriveBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post>> deletePost(Request Function(PostDeleteBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').retrive<Post>(
      typeResolver: Post(),
      request: builder(PostDeleteBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post>> createPost(Request Function(PostCreateBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').create<Post>(
      typeResolver: Post(),
      request: builder(PostCreateBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }
}
