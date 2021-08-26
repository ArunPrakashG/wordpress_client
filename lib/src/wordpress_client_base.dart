import 'package:dio/dio.dart';
import 'package:wordpress_client/src/builders/retrive/comment_retrive.dart';
import 'package:wordpress_client/src/builders/update/comment_update.dart';

import 'builders/create/comment_create.dart';
import 'builders/delete/comment_delete.dart';
import 'builders/list/comment_list.dart';
import 'builders_import.dart';
import 'client_configuration.dart';
import 'exceptions/client_not_initialized_exception.dart';
import 'exceptions/interface_do_not_exist_exception.dart';
import 'exceptions/interface_exist_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'internal_requester.dart';
import 'operations/create.dart';
import 'operations/delete.dart';
import 'operations/list.dart';
import 'operations/retrive.dart';
import 'operations/update.dart';
import 'responses/comment_response.dart';
import 'responses_import.dart';
import 'utilities/helpers.dart';
import 'utilities/serializable_instance.dart';

part 'interface/category.dart';
part 'interface/comments.dart';
part 'interface/custom.dart';
part 'interface/me.dart';
part 'interface/media.dart';
part 'interface/posts.dart';
part 'interface/tags.dart';
part 'interface/users.dart';

late InternalRequester _requester;

Future<InternalRequester> _getInternalRequesterClient({bool shouldWaitIfBusy = false}) async {
  if (shouldWaitIfBusy) {
    while (_requester.getBusyStatus()!) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  return _requester;
}

class WordpressClient {
  Map<String, dynamic>? _interfaces;
  static String? baseUrl;

  late MeInterface meInterface;

  WordpressClient(String? baseUrl, String? path, {BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper}) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    WordpressClient.baseUrl = baseUrl;

    _requester = InternalRequester(
      baseUrl,
      path,
      bootstrapper == null ? null : bootstrapper(BootstrapBuilder()),
    );
    _initializeInterfaces();
  }

  void reconfigureRequester(BootstrapConfiguration Function(BootstrapBuilder) bootstrapper) => _requester.configure(bootstrapper(BootstrapBuilder()));

  void _initializeInterfaces() {
    _interfaces ??= new Map<String, dynamic>();
    _interfaces!['posts'] = PostsInterface<Post>();
    _interfaces!['users'] = UsersInterface<User>();
    _interfaces!['me'] = MeInterface<User>();
    _interfaces!['media'] = MediaInterface<Media>();
    _interfaces!['categories'] = CategoryInterface<Category>();
    _interfaces!['tags'] = TagInterface<Tag>();
    _interfaces!['comments'] = CommentInterface<Comment>();
  }

  T? getInterfaceById<T>(String id) {
    if (_interfaces == null || _interfaces!.isEmpty) {
      throw ClientNotInitializedException('Please correctly initialize WordpressClient before retriving the available interfaces.');
    }

    if (isNullOrEmpty(id)) {
      throw NullReferenceException('Interface ID is invalid.');
    }

    if (_interfaces![id] == null) {
      throw InterfaceDoNotExistException('$id interface do not exist.');
    }

    return _interfaces![id];
  }

  Future<ResponseContainer<List<User?>?>> listUsers(Request Function(UserListBuilder) builder) async {
    return _getInterfaceById<UsersInterface<User>>('users')!.list<User>(
      typeResolver: User(),
      request: builder(UserListBuilder().withEndpoint('users').initializeWithDefaultValues()) as Request<List<User>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User?>> retriveUser(Request Function(UserRetriveBuilder) builder) async {
    return _getInterfaceById<UsersInterface<User>>('users')!.retrive<User>(
      typeResolver: User(),
      request: builder(UserRetriveBuilder().withEndpoint('users').initializeWithDefaultValues()) as Request<User>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User?>> deleteUser(Request Function(UserDeleteBuilder) builder) async {
    return _getInterfaceById<UsersInterface<User>>('users')!.delete<User>(
      typeResolver: User(),
      request: builder(UserDeleteBuilder().withEndpoint('users').initializeWithDefaultValues()) as Request<User>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User?>> updateUser(Request Function(UserUpdateBuilder) builder) async {
    return _getInterfaceById<UsersInterface<User>>('users')!.update<User>(
      typeResolver: User(),
      request: builder(UserUpdateBuilder().withEndpoint('users').initializeWithDefaultValues()) as Request<User>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<User?>> createUser(Request Function(UserCreateBuilder) builder) async {
    return _getInterfaceById<UsersInterface<User>>('users')!.create<User>(
      typeResolver: User(),
      request: builder(UserCreateBuilder().withEndpoint('users').initializeWithDefaultValues()) as Request<User>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post?>> updatePost(Request Function(PostUpdateBuilder) builder) async {
    return _getInterfaceById<PostsInterface<Post>>('posts')!.update<Post>(
      typeResolver: Post(),
      request: builder(PostUpdateBuilder().withEndpoint('posts').initializeWithDefaultValues()) as Request<Post>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Post?>?>> listPost(Request Function(PostListBuilder) builder) async {
    return _getInterfaceById<PostsInterface<Post>>('posts')!.list<Post>(
      typeResolver: Post(),
      request: builder(PostListBuilder().withEndpoint('posts').initializeWithDefaultValues()) as Request<List<Post>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post?>> retrivePost(Request Function(PostRetriveBuilder) builder) async {
    return _getInterfaceById<PostsInterface<Post>>('posts')!.retrive<Post>(
      typeResolver: Post(),
      request: builder(PostRetriveBuilder().withEndpoint('posts').initializeWithDefaultValues()) as Request<Post>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post?>> deletePost(Request Function(PostDeleteBuilder) builder) async {
    return _getInterfaceById<PostsInterface<Post>>('posts')!.delete<Post>(
      typeResolver: Post(),
      request: builder(PostDeleteBuilder().withEndpoint('posts').initializeWithDefaultValues()) as Request<Post>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Post?>> createPost(Request Function(PostCreateBuilder) builder) async {
    return _getInterfaceById<PostsInterface<Post>>('posts')!.create<Post>(
      typeResolver: Post(),
      request: builder(PostCreateBuilder().withEndpoint('posts').initializeWithDefaultValues()) as Request<Post>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media?>> createMedia(Request Function(MediaCreateBuilder) builder) async {
    return _getInterfaceById<MediaInterface<Media>>('media')!.create<Media>(
      typeResolver: Media(),
      request: builder(MediaCreateBuilder().withEndpoint('media').initializeWithDefaultValues()) as Request<Media>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media?>> deleteMedia(Request Function(MediaDeleteBuilder) builder) async {
    return _getInterfaceById<MediaInterface<Media>>('media')!.delete<Media>(
      typeResolver: Media(),
      request: builder(MediaDeleteBuilder().withEndpoint('media').initializeWithDefaultValues()) as Request<Media>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Media?>?>> listMedia(Request Function(MediaListBuilder) builder) async {
    return _getInterfaceById<MediaInterface<Media>>('media')!.list<Media>(
      typeResolver: Media(),
      request: builder(MediaListBuilder().withEndpoint('media').initializeWithDefaultValues()) as Request<List<Media>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media?>> retriveMedia(Request Function(MediaRetriveBuilder) builder) async {
    return _getInterfaceById<MediaInterface<Media>>('media')!.retrive<Media>(
      typeResolver: Media(),
      request: builder(MediaRetriveBuilder().withEndpoint('media').initializeWithDefaultValues()) as Request<Media>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Media?>> updateMedia(Request Function(MediaUpdateBuilder) builder) async {
    return _getInterfaceById<MediaInterface<Media>>('media')!.update<Media>(
      typeResolver: Media(),
      request: builder(MediaUpdateBuilder().withEndpoint('media').initializeWithDefaultValues()) as Request<Media>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Category?>?>> listCategory(Request Function(CategoryListBuilder) builder) async {
    return _getInterfaceById<CategoryInterface<Category>>('categories')!.list<Category>(
      typeResolver: Category(),
      request: builder(CategoryListBuilder().withEndpoint('categories').initializeWithDefaultValues()) as Request<List<Category>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category?>> retriveCategory(Request Function(CategoryRetriveBuilder) builder) async {
    return _getInterfaceById<CategoryInterface<Category>>('categories')!.retrive<Category>(
      typeResolver: Category(),
      request: builder(CategoryRetriveBuilder().withEndpoint('categories').initializeWithDefaultValues()) as Request<Category>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category?>> deleteCategory(Request Function(CategoryDeleteBuilder) builder) async {
    return _getInterfaceById<CategoryInterface<Category>>('categories')!.delete<Category>(
      typeResolver: Category(),
      request: builder(CategoryDeleteBuilder().withEndpoint('categories').initializeWithDefaultValues()) as Request<Category>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category?>> updateCategory(Request Function(CategoryUpdateBuilder) builder) async {
    return _getInterfaceById<CategoryInterface<Category>>('categories')!.update<Category>(
      typeResolver: Category(),
      request: builder(CategoryUpdateBuilder().withEndpoint('categories').initializeWithDefaultValues()) as Request<Category>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Category?>> createCategory(Request Function(CategoryCreateBuilder) builder) async {
    return _getInterfaceById<CategoryInterface<Category>>('categories')!.create<Category>(
      typeResolver: Category(),
      request: builder(CategoryCreateBuilder().withEndpoint('categories').initializeWithDefaultValues()) as Request<Category>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag?>> createTag(Request Function(TagCreateBuilder) builder) async {
    return _getInterfaceById<TagInterface<Tag>>('tags')!.create<Tag>(
      typeResolver: Tag(),
      request: builder(TagCreateBuilder().withEndpoint('tags').initializeWithDefaultValues()) as Request<Tag>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag?>> updateTag(Request Function(TagUpdateBuilder) builder) async {
    return _getInterfaceById<TagInterface<Tag>>('tags')!.update<Tag>(
      typeResolver: Tag(),
      request: builder(TagUpdateBuilder().withEndpoint('tags').initializeWithDefaultValues()) as Request<Tag>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag?>> retriveTag(Request Function(TagRetriveBuilder) builder) async {
    return _getInterfaceById<TagInterface<Tag>>('tags')!.retrive<Tag>(
      typeResolver: Tag(),
      request: builder(TagRetriveBuilder().withEndpoint('tags').initializeWithDefaultValues()) as Request<Tag>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Tag?>?>> listTag(Request Function(TagListBuilder) builder) async {
    return _getInterfaceById<TagInterface<Tag>>('tags')!.list<Tag>(
      typeResolver: Tag(),
      request: builder(TagListBuilder().withEndpoint('tags').initializeWithDefaultValues()) as Request<List<Tag>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Tag?>> deleteTag(Request Function(TagDeleteBuilder) builder) async {
    return _getInterfaceById<TagInterface<Tag>>('tags')!.delete<Tag>(
      typeResolver: Tag(),
      request: builder(TagDeleteBuilder().withEndpoint('tags').initializeWithDefaultValues()) as Request<Tag>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<List<Comment?>?>> listComment(Request Function(CommentListBuilder) builder) async {
    return _getInterfaceById<CommentInterface<Comment>>('comments')!.list<Comment>(
      typeResolver: Comment(),
      request: builder(CommentListBuilder().withEndpoint('comments').initializeWithDefaultValues()) as Request<List<Comment>>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Comment?>> deleteComment(Request Function(CommentDeleteBuilder) builder) async {
    return _getInterfaceById<CommentInterface<Comment>>('comments')!.delete<Comment>(
      typeResolver: Comment(),
      request: builder(CommentDeleteBuilder().withEndpoint('comments').initializeWithDefaultValues()) as Request<Comment>?,
      requesterClient: _requester,
    );
  }

  Future<ResponseContainer<Comment?>> createComment(Request Function(CommentCreateBuilder) builder) async {
    return _getInterfaceById<CommentInterface<Comment>>('comments')!.create<Comment>(
      typeResolver: Comment(),
      request: builder(CommentCreateBuilder().withEndpoint('comments').initializeWithDefaultValues()) as Request<Comment>?,
      requesterClient: _requester,
    );
  }
}
