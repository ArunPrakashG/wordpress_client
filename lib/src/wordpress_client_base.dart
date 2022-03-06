import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../wordpress_client.dart';
import 'bootstrap_builder.dart';
import 'client_configuration.dart';
import 'exceptions/interface_do_not_exist_exception.dart';
import 'exceptions/interface_exist_exception.dart';
import 'exceptions/interface_not_initialized.dart';
import 'exceptions/invalid_interface_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'exceptions/request_uri_parse_exception.dart';
import 'interface/category.dart';
import 'interface/comments.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'interface/tags.dart';
import 'interface/users.dart';
import 'responses/comment_response.dart';
import 'type_map.dart';
import 'utilities/helpers.dart';

part 'internal_requester.dart';

class WordpressClient {
  WordpressClient(
    String baseUrl,
    String path, {
    BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper,
  }) {
    if (isNullOrEmpty(baseUrl)) {
      throw const NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw const NullReferenceException('Path is invalid.');
    }

    requestBaseUrl = baseUrl;
    requestPath = path;
    requestBaseWithPath = parseUrl(baseUrl, path);

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester(
      baseUrl: baseUrl,
      path: path,
      configuration: configuration,
    );
  }

  late InternalRequester _requester;

  /// Base url supplied through constructor.
  static late String requestBaseUrl;

  /// Base url path supplied through constructor.
  static late String requestPath;

  /// Combined url of [requestBaseUrl] and [requestPath]
  static String requestBaseWithPath = '';

  /// Stores data on how to decode & encode responses.
  final TypeMap _typeMap = TypeMap();

  /// The current user interface.
  ///
  /// Requests will only work if you are authorized with valid credentials.
  MeInterface get me => _interfaces['me'] as MeInterface;

  PostsInterface get posts => _interfaces['posts'] as PostsInterface;
  CategoryInterface get categories =>
      _interfaces['categories'] as CategoryInterface;
  CommentInterface get comments => _interfaces['comments'] as CommentInterface;
  MediaInterface get media => _interfaces['media'] as MediaInterface;
  TagInterface get tags => _interfaces['tags'] as TagInterface;
  UsersInterface get users => _interfaces['users'] as UsersInterface;

  static final Map<String, dynamic> _interfaces = <String, dynamic>{};

  bool _hasInitialized = false;

  /// Initializes all the built in interfaces and other services/
  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }

    await _initInternalInterfaces();
    _hasInitialized = true;
  }

  Future<void> _initInternalInterfaces() async {
    await initInterface<MeInterface, User>(
      interface: MeInterface(),
      key: 'me',
      responseDecoder: User.fromJson,
      responseEncoder: (dynamic user) => (user as User).toJson(),
      overriteIfTypeExists: true,
    );

    await initInterface<PostsInterface, Post>(
      interface: PostsInterface(),
      key: 'posts',
      responseDecoder: Post.fromJson,
      responseEncoder: (dynamic post) => (post as Post).toJson(),
    );

    await initInterface<CategoryInterface, Category>(
      interface: CategoryInterface(),
      key: 'categories',
      responseDecoder: Category.fromJson,
      responseEncoder: (dynamic category) => (category as Category).toJson(),
    );

    await initInterface<CommentInterface, Comment>(
      interface: CommentInterface(),
      key: 'comments',
      responseDecoder: Comment.fromJson,
      responseEncoder: (dynamic comment) => (comment as Comment).toJson(),
    );

    await initInterface<MediaInterface, Media>(
      interface: MediaInterface(),
      key: 'media',
      responseDecoder: Media.fromJson,
      responseEncoder: (dynamic media) => (media as Media).toJson(),
    );

    await initInterface<TagInterface, Tag>(
      interface: TagInterface(),
      key: 'tags',
      responseDecoder: Tag.fromJson,
      responseEncoder: (dynamic tag) => (tag as Tag).toJson(),
    );

    // TODO: Add a tag parameter to type map, so that we can have multiple maps of same type.
    await initInterface<UsersInterface, User>(
      interface: UsersInterface(),
      key: 'users',
      responseDecoder: User.fromJson,
      responseEncoder: (dynamic user) => (user as User).toJson(),
      overriteIfTypeExists: true,
    );
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IInterface] abstract class, which provides internal requester instance and other functions.
  ///
  /// [key] must be unique to this instance of [WordpressClient] as this will be used to indentify the instance.
  ///
  /// [interface] is instance of interface type [T]
  ///
  /// [responseDecoder] is a function that takes a json object and returns an instance of [T]
  /// [responseEncoder] is a function that takes an instance of [T] and returns a json object
  /// These are required to decode and encode responses for this interface.
  ///
  /// [overriteIfTypeExists] is a boolean that determines if the type should be overwritten if it already exists.
  ///
  /// Some keys are already occupied:
  /// - `me`
  /// - `posts`
  /// - `categories`
  /// - `comments`
  /// - `media`
  /// - `tags`
  /// - `users`
  ///
  /// Example usage:
  ///
  /// ```dart
  /// await initInterface<UsersInterface, User>(
  ///   interface: CustomInterface(),
  ///   key: 'custom_interface_key',
  ///   responseDecoder: [CustomResponseObject].fromJson,
  ///   responseEncoder: (dynamic response) => (response as [CustomResponseObject]).toJson(),
  /// );
  /// ```
  ///
  Future<void> initInterface<T extends IInterface, E>({
    required T? interface,
    required String? key,
    required JsonEncoderCallback responseEncoder,
    required JsonDecoderCallback<E> responseDecoder,
    bool overriteIfTypeExists = false,
  }) async {
    if (interface == null || isNullOrEmpty(key)) {
      throw const InvalidInterfaceException();
    }

    if (_interfaces[key] != null) {
      throw InterfaceExistException('[$key] Interface already exists.');
    }

    registerResponseType<E>(
      decoder: responseDecoder,
      encoder: responseEncoder,
      overriteIfExists: overriteIfTypeExists,
    );

    await interface.init(_requester, key);
    _interfaces[key!] = interface;
  }

  /// Registers a type to be used in [WordpressClient] Responses.
  ///
  /// This is called automatically on [initInterface], During initializing of an interface.
  ///
  /// By default, all respones used inside [WordpressClient] library is registered. If you try to register them again, it will throw [MapAlreadyExistException] exception.
  ///
  /// [decoder] is a function that takes a json object and returns an instance of [E]
  /// [encoder] is a function that takes an instance of [E] and returns a json object
  /// These are required to decode and encode responses.
  ///
  /// [overriteIfExists] is a boolean that determines if the type should be overwritten if it already exists.
  void registerResponseType<E>({
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<E> decoder,
    bool overriteIfExists = false,
  }) {
    _typeMap.addJsonPairForType<E>(
      decoder: decoder,
      encoder: encoder,
      overriteIfExists: overriteIfExists,
    );
  }

  /// Gets an initialized interface.
  ///
  /// [key] parameter is optional. However, getting result by specifing key is faster than using type.
  ///
  /// All custom interfaces must inherit from [IInterface] interface.
  ///
  /// Calling this method without initializing the custom interface using `initCustomInterface<T>(...)` will result in `InterfaceNotInitializedException`
  ///
  /// Example usage:
  ///
  /// ```dart
  /// await client.getCustomInterface<MyCustomInterface>().create((p1) => p1.build());
  /// ```
  ///
  T getCustomInterface<T extends IInterface>([String? key]) {
    if (!isNullOrEmpty(key) && _interfaces[key] != null) {
      return _interfaces[key] as T;
    }

    final interfacesOfType = _interfaces.values.whereType<T>();

    if (interfacesOfType.isEmpty) {
      throw const InterfaceDoNotExistException(
          'The specified interface do not exist.');
    }

    final interface = interfacesOfType.first;

    if (!interface.hasInitilizedAlready) {
      throw const InterfaceNotInitializedException();
    }

    return interface;
  }

  void removeDefaultAuthorization() => _requester.removeDefaultAuthorization();

  void reconfigureRequester(
    BootstrapConfiguration Function(BootstrapBuilder) bootstrapper,
  ) {
    return _requester.configure(bootstrapper(BootstrapBuilder()));
  }
}
