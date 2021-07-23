import 'builders_import.dart';
import 'client_configuration.dart';
import 'exceptions/client_not_initialized_exception.dart';
import 'exceptions/interface_do_not_exist_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'interface/category.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'interface/tags.dart';
import 'interface/users.dart';
import 'internal_requester.dart';
import 'responses_import.dart';
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
    _interfaces['categories'] = CategoryInterface<Category>();
    _interfaces['tags'] = TagInterface<Tag>();
  }

  T getInterfaceByName<T>(String name) {
    if (_interfaces == null || _interfaces.isEmpty) {
      throw ClientNotInitializedException('Please correctly initialize WordpressClient before retriving the available interfaces.');
    }

    if (isNullOrEmpty(name)) {
      throw NullReferenceException('Interface name is invalid.');
    }

    if (_interfaces[name] == null) {
      throw InterfaceDoNotExistException('$name interface do not exist.');
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
      typeResolver: User(),
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
      typeResolver: Post(),
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
      typeResolver: Media(),
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

  Future<ResponseContainer<List<Category>>> listCategory(Request Function(CategoryListBuilder) builder) async {
    return getInterfaceByName<CategoryInterface<Category>>('categories').list<Category>(
      typeResolver: Category(),
      request: builder(CategoryListBuilder().withEndpoint('categories').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category>> retriveCategory(Request Function(CategoryRetriveBuilder) builder) async {
    return getInterfaceByName<CategoryInterface<Category>>('categories').retrive<Category>(
      typeResolver: Category(),
      request: builder(CategoryRetriveBuilder().withEndpoint('categories').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category>> deleteCategory(Request Function(CategoryDeleteBuilder) builder) async {
    return getInterfaceByName<CategoryInterface<Category>>('categories').delete<Category>(
      typeResolver: Category(),
      request: builder(CategoryDeleteBuilder().withEndpoint('categories').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category>> updateCategory(Request Function(CategoryUpdateBuilder) builder) async {
    return getInterfaceByName<CategoryInterface<Category>>('categories').update<Category>(
      typeResolver: Category(),
      request: builder(CategoryUpdateBuilder().withEndpoint('categories').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category>> createCategory(Request Function(CategoryCreateBuilder) builder) async {
    return getInterfaceByName<CategoryInterface<Category>>('categories').create<Category>(
      typeResolver: Category(),
      request: builder(CategoryCreateBuilder().withEndpoint('categories').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag>> createTag(Request Function(TagCreateBuilder) builder) async {
    return getInterfaceByName<TagInterface<Tag>>('tags').create<Tag>(
      typeResolver: Tag(),
      request: builder(TagCreateBuilder().withEndpoint('tags').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag>> updateTag(Request Function(TagUpdateBuilder) builder) async {
    return getInterfaceByName<TagInterface<Tag>>('tags').update<Tag>(
      typeResolver: Tag(),
      request: builder(TagUpdateBuilder().withEndpoint('tags').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag>> retriveTag(Request Function(TagRetriveBuilder) builder) async {
    return getInterfaceByName<TagInterface<Tag>>('tags').retrive<Tag>(
      typeResolver: Tag(),
      request: builder(TagRetriveBuilder().withEndpoint('tags').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Tag>>> listTag(Request Function(TagListBuilder) builder) async {
    return getInterfaceByName<TagInterface<Tag>>('tags').list<Tag>(
      typeResolver: Tag(),
      request: builder(TagListBuilder().withEndpoint('tags').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag>> deleteTag(Request Function(TagDeleteBuilder) builder) async {
    return getInterfaceByName<TagInterface<Tag>>('tags').delete<Tag>(
      typeResolver: Tag(),
      request: builder(TagDeleteBuilder().withEndpoint('tags').initializeWithDefaultValues()),
      requesterClient: _requester,
    );
  }
}
