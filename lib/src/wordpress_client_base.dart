import 'builders/bootstrap_builder.dart';
import 'builders/create/media_create.dart';
import 'builders/create/post_create.dart';
import 'builders/create/user_create.dart';
import 'builders/delete/me_delete.dart';
import 'builders/delete/media_delete.dart';
import 'builders/delete/post_delete.dart';
import 'builders/delete/user_delete.dart';
import 'builders/list/media_list.dart';
import 'builders/list/post_list.dart';
import 'builders/list/user_list.dart';
import 'builders/request.dart';
import 'builders/retrive/me_retrive.dart';
import 'builders/retrive/media_retrive.dart';
import 'builders/retrive/post_retrive.dart';
import 'builders/retrive/user_retrive.dart';
import 'builders/update/me_update.dart';
import 'builders/update/media_update.dart';
import 'builders/update/post_update.dart';
import 'builders/update/user_update.dart';
import 'client_configuration.dart';
import 'exceptions/client_not_initialized_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'interface/users.dart';
import 'internal_requester.dart';
import 'responses/media_response.dart';
import 'responses/post_response.dart';
import 'responses/response_container.dart';
import 'responses/user_response.dart';
import 'utilities/helpers.dart';

class WordpressClient {
  Map<String, dynamic> _interfaces;
  InternalRequester _requester;
  static String baseUrl;

  WordpressClient(String baseUrl, String path, {BootstrapConfiguration Function(BootstrapBuilder) bootstrapper}) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    WordpressClient.baseUrl = baseUrl;

    _requester = InternalRequester(baseUrl, path, bootstrapper(BootstrapBuilder()));
    _initializeInterfaces();
  }

  void _initializeInterfaces() {
    _interfaces ??= new Map<String, dynamic>();
    _interfaces['posts'] = PostsInterface<Post>();
    _interfaces['users'] = UsersInterface<User>();
    _interfaces['me'] = MeInterface<User>();
    _interfaces['media'] = MediaInterface<Media>();
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

  Future<ResponseContainer<User>> retriveMe(Request Function(MeRetriveBuilder) builder) async {
    return getInterfaceByName<MeInterface<User>>('me').retrive<User>(
      typeResolver: User(),
      request: builder(MeRetriveBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> deleteMe(Request Function(MeDeleteBuilder) builder) async {
    return getInterfaceByName<MeInterface<User>>('me').delete<User>(
      typeResolver: User(),
      request: builder(MeDeleteBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> updateMe(Request Function(MeUpdateBuilder) builder) async {
    return getInterfaceByName<MeInterface<User>>('me').update<User>(
      typeResolver: User(),
      request: builder(MeUpdateBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
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
    return getInterfaceByName<UsersInterface<User>>('users').delete<User>(
      typeResolver: User(),
      request: builder(UserDeleteBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> updateUser(Request Function(UserUpdateBuilder) builder) async {
    return getInterfaceByName<UsersInterface<User>>('users').update<User>(
      typeResolver: User(),
      request: builder(UserUpdateBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User>> createUser(Request Function(UserCreateBuilder) builder) async {
    return getInterfaceByName<UsersInterface<User>>('users').create<User>(
      typeResolver: User(),
      request: builder(UserCreateBuilder().withEndpoint('users').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post>> updatePost(Request Function(PostUpdateBuilder) builder) async {
    return getInterfaceByName<PostsInterface<Post>>('posts').update<Post>(
      typeResolver: Post(),
      request: builder(PostUpdateBuilder().withEndpoint('posts').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Post>>> listPost(Request Function(PostListBuilder) builder) async {
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
    return getInterfaceByName<PostsInterface<Post>>('posts').delete<Post>(
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

  Future<ResponseContainer<Media>> createMedia(Request Function(MediaCreateBuilder) builder) async {
    return getInterfaceByName<MediaInterface<Media>>('media').create<Media>(
      typeResolver: Media(),
      request: builder(MediaCreateBuilder().withEndpoint('media').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media>> deleteMedia(Request Function(MediaDeleteBuilder) builder) async {
    return getInterfaceByName<MediaInterface<Media>>('media').delete<Media>(
      typeResolver: Media(),
      request: builder(MediaDeleteBuilder().withEndpoint('media').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Media>>> listMedia(Request Function(MediaListBuilder) builder) async {
    return getInterfaceByName<MediaInterface<Media>>('media').list<Media>(
      resolver: Media(),
      request: builder(MediaListBuilder().withEndpoint('media').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media>> retriveMedia(Request Function(MediaRetriveBuilder) builder) async {
    return getInterfaceByName<MediaInterface<Media>>('media').retrive<Media>(
      typeResolver: Media(),
      request: builder(MediaRetriveBuilder().withEndpoint('media').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media>> updateMedia(Request Function(MediaUpdateBuilder) builder) async {
    return getInterfaceByName<MediaInterface<Media>>('media').update<Media>(
      typeResolver: Media(),
      request: builder(MediaUpdateBuilder().withEndpoint('media').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }
}
