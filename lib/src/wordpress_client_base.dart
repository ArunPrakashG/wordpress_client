import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:synchronized/synchronized.dart' as sync;

import 'bootstrap_builder.dart';
import 'exceptions/exceptions_export.dart';
import 'interface_key.dart';
import 'library_exports.dart';
import 'responses/responses_export.dart';
import 'services/category.dart';
import 'services/comments.dart';
import 'services/me.dart';
import 'services/media.dart';
import 'services/posts.dart';
import 'services/search.dart';
import 'services/tags.dart';
import 'services/users.dart';
import 'type_map.dart';
import 'utilities/helpers.dart';
import 'utilities/utility_export.dart';

part 'authorization/authorization_base.dart';
part 'internal_requester.dart';

/// The main class for [WordpressClient].
class WordpressClient {
  /// Default Constructor.
  ///
  /// [baseUrl] is the base url of the wordpress site.
  /// [path] is the path of the url appended to your REST API.
  /// [bootstrapper] is a builder method for initializing the client.
  ///
  /// After this, you will have to initialize the client with [initialize] method call.
  ///
  /// In order to handle initialization in the constructor itself, call [WordpressClient.initialize] factory constructor.
  ///
  /// You can change [path] per request basis as well. You will have to assign it in `build()` method of request class which inherits from [IRequest].
  WordpressClient(
    String baseUrl,
    String path, {
    BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper,
  }) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    if (baseUrl.contains('www.')) {
      baseUrl = baseUrl.replaceFirst('www.', '');
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      path,
      configuration,
    );
  }

  /// Default Constructor but with initialization.
  ///
  /// [baseUrl] is the base url of the wordpress site.
  /// [path] is the path of the url appended to your REST API.
  /// [bootstrapper] is a builder method for initializing the client.
  ///
  WordpressClient.initialize(
    String baseUrl,
    String path, {
    BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper,
  }) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    if (baseUrl.contains('www.')) {
      baseUrl = baseUrl.replaceFirst('www.', '');
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      path,
      configuration,
    );

    initialize();
  }

  late final InternalRequester _requester;

  /// Base url supplied through constructor.
  String get baseUrl => _requester._baseUrl;

  /// Base url path supplied through constructor.
  String get path => _requester._path;

  /// Returns true if this instance of [WordpressClient] is running in debug mode.
  ///
  /// i.e., [LogInterceptor] of [Dio] is attached to [Dio] instance which prints every request & response to console.
  bool get isDebugMode => _requester._isDebugMode;

  /// Returns true if we have synchronized mode enabled.
  ///
  /// i.e., Only a single request is allowed at a time.
  bool get isSynchronizedMode => _requester._synchronized;

  /// Returns true if we have valid default authorization which is to be used for all requests.
  bool get hasValidDefaultAuthorization =>
      _requester._defaultAuthorization != null &&
      _requester._defaultAuthorization!.isValidAuth;

  /// Combined url of [baseUrl] and [path]
  String get requestUrl => _requester.requestBaseUrl;

  /// Stores data on how to decode & encode responses.
  final TypeMap _typeMap = TypeMap();

  /// The current user interface.
  ///
  /// Provides functionality to manipulate current authorized user.
  ///
  /// Available Operations:
  /// - Retrive (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  MeService get me => getInterface<MeService>('me');

  /// The posts interface.
  ///
  /// Provides functionality to manipulate posts.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  PostsService get posts => getInterface<PostsService>('posts');

  /// The categories interface.
  ///
  /// Provides functionality to manipulate categories.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  CategoryService get categories => getInterface<CategoryService>('categories');

  /// The comments interface.
  ///
  /// Provides functionality to manipulate comments.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  CommentService get comments => getInterface<CommentService>('comments');

  /// The media interface.
  ///
  /// Provides functionality to manipulate media.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  MediaService get media => getInterface<MediaService>('media');

  /// The tags interface.
  ///
  /// Provides functionality to manipulate tags.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  TagService get tags => getInterface<TagService>('tags');

  /// The users interface.
  ///
  /// Provides functionality to manipulate users.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  UsersService get users => getInterface<UsersService>('users');

  /// The search interface.
  ///
  /// Provides functionality to search posts, terms, post-formats.
  ///
  /// Available Operations:
  /// - List
  ///
  SearchService get search => getInterface<SearchService>('search');

  final Map<InterfaceKey<dynamic>, dynamic> _interfaces =
      <InterfaceKey<dynamic>, dynamic>{};

  bool _hasInitialized = false;

  /// Status on if the client has been initialized successfully.
  ///
  /// This will be true if [initialize] method has been called and completed.
  bool get isReady => _hasInitialized;

  /// Initializes all the built in interfaces and other services
  ///
  /// This method should be called before any other method.
  ///
  void initialize() {
    if (_hasInitialized) {
      return;
    }

    _initInternalInterfaces();
    _hasInitialized = true;
  }

  void _initInternalInterfaces() {
    initInterface<MeService, User>(
      interface: MeService(),
      key: 'me',
      responseDecoder: (map) => User.fromJson(map),
      responseEncoder: (dynamic user) => (user as User).toJson(),
    );

    initInterface<PostsService, Post>(
      interface: PostsService(),
      key: 'posts',
      responseDecoder: (map) => Post.fromJson(map),
      responseEncoder: (dynamic post) => (post as Post).toJson(),
    );

    initInterface<CategoryService, Category>(
      interface: CategoryService(),
      key: 'categories',
      responseDecoder: (map) => Category.fromJson(map),
      responseEncoder: (dynamic category) => (category as Category).toJson(),
    );

    initInterface<CommentService, Comment>(
      interface: CommentService(),
      key: 'comments',
      responseDecoder: (map) => Comment.fromJson(map),
      responseEncoder: (dynamic comment) => (comment as Comment).toJson(),
    );

    initInterface<MediaService, Media>(
      interface: MediaService(),
      key: 'media',
      responseDecoder: (map) => Media.fromJson(map),
      responseEncoder: (dynamic media) => (media as Media).toJson(),
    );

    initInterface<TagService, Tag>(
      interface: TagService(),
      key: 'tags',
      responseDecoder: (map) => Tag.fromJson(map),
      responseEncoder: (dynamic tag) => (tag as Tag).toJson(),
    );

    initInterface<UsersService, User>(
      interface: UsersService(),
      key: 'users',
      responseDecoder: (map) => User.fromJson(map),
      responseEncoder: (dynamic user) => (user as User).toJson(),
    );

    initInterface<SearchService, Search>(
      interface: SearchService(),
      key: 'search',
      responseDecoder: (map) => Search.fromJson(map),
      responseEncoder: (dynamic search) => (search as Search).toJson(),
    );
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IWordpressService] abstract class, which provides internal requester instance and other functions.
  ///
  /// [key] must be unique to this instance of [WordpressClient] as this will be used to indentify the instance & the response type used by the interface requests.
  ///
  /// [interface] is instance of interface type [T]
  ///
  /// [responseDecoder] is a function that takes a json object and returns an instance of [T]
  ///
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
  /// - `search`
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
  void initInterface<T extends IWordpressService, E>({
    required T interface,
    required String key,
    required JsonEncoderCallback responseEncoder,
    required JsonDecoderCallback<E> responseDecoder,
    bool overriteIfTypeExists = false,
  }) {
    final interfaceKey = InterfaceKey<T>(key);

    if (_interfaces[interfaceKey] != null) {
      throw InterfaceExistException<T>();
    }

    _registerResponseType<E>(
      decoder: responseDecoder,
      encoder: responseEncoder,
      overriteIfExists: overriteIfTypeExists,
    );

    interface._initInterface(
      _requester,
      interfaceKey,
    );

    _interfaces[interfaceKey] = interface;
  }

  /// Checks if an interface with the given Type [T] and [key] exists.
  bool interfaceExists<T>([String? key]) =>
      _interfaces[InterfaceKey<T>(key)] != null;

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
  void _registerResponseType<E>({
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<E> decoder,
    bool overriteIfExists = false,
  }) {
    _typeMap.addJsonPairForType<E>(
      decoder: decoder,
      encoder: encoder,
      overwrite: overriteIfExists,
    );
  }

  /// Gets an initialized interface.
  ///
  /// [key] parameter is optional. However, getting result by specifing key is faster.
  ///
  /// All custom interfaces must inherit from [IWordpressService] interface.
  ///
  /// Calling this method without initializing the custom interface using `initCustomInterface<T>(...)` will result in `InterfaceNotInitializedException`
  ///
  /// Example usage:
  ///
  /// ```dart
  /// await client.getCustomInterface<MyCustomInterface>().create((p1) => p1.build());
  /// ```
  ///
  T getInterface<T extends IWordpressService>([String? key]) {
    if (!isReady) {
      throw ClientNotReadyException();
    }

    final interfaceKey = InterfaceKey<T>(key);

    if (interfaceExists<T>(key)) {
      return _interfaces[interfaceKey] as T;
    }

    final interfacesOfType = _interfaces.values.whereType<T>();

    if (interfacesOfType.isEmpty) {
      throw InterfaceDoNotExistException(
          'The specified interface do not exist. (${typeOf<T>()}_$key)');
    }

    final interface = interfacesOfType.first;

    if (!interface._hasInitilizedAlready) {
      throw InterfaceNotInitializedException<T>();
    }

    return interface;
  }

  /// Clears default authorization if exists.
  void clearDefaultAuthorization() => _requester._removeDefaultAuthorization();

  /// Called to reconfigure the client with new settings.
  ///
  /// The default builder will contain all the previous settings.
  ///
  /// Only the settings that have changed since will be updated.
  void reconfigureClient(
    BootstrapConfiguration Function(BootstrapBuilder) bootstrapper,
  ) {
    return _requester.configure(
      bootstrapper(
        BootstrapBuilder.fromConfiguration(
          _requester._configuration,
        ),
      ),
    );
  }
}

/// The base of all request interfaces.
/// You must extend from this interface to define custom requests.
abstract class IWordpressService {
  /// The internal requester instance.
  ///
  /// This variable is assigned on init method automatically.
  late final InternalRequester internalRequester;

  /// The interface key, this must be unique and will act as a unique identifier for this interface.
  late final InterfaceKey<dynamic> interfaceKey;

  bool _hasInitilizedAlready = false;

  /// This method is used to initialize the interface by passing [InternalRequester] instance from the core to the interface.
  ///
  /// This method is called only once in interface lifecycle.
  ///
  /// It should always call super init() if it is overriden like so `super.init(requester, key)`.
  /// Failing to call super init() method means [internalRequester] variable will be null and therefore none of the requests will go through and throws exception.
  ///
  /// Or you have to handle default init process by:
  ///
  /// ```dart
  /// if(!hasInitilizedAlready){
  ///   internalRequester = requester;
  ///   interfaceKey = key;
  ///   hasInitilizedAlready = true;
  /// }
  /// ```
  ///
  void _initInterface(
    InternalRequester requester,
    InterfaceKey<dynamic> key,
  ) {
    if (_hasInitilizedAlready) {
      return;
    }

    internalRequester = requester;
    interfaceKey = key;
    _hasInitilizedAlready = true;
    onInit();
  }

  /// This method is called right after internal initialization process of the interface completes.
  void onInit() {}
}
