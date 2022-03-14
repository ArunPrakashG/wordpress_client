import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:synchronized/synchronized.dart' as sync;

import 'bootstrap_builder.dart';
import 'exceptions/exceptions_export.dart';
import 'interface/category.dart';
import 'interface/comments.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'interface/tags.dart';
import 'interface/users.dart';
import 'interface_key.dart';
import 'library_exports.dart';
import 'responses/responses_export.dart';
import 'type_map.dart';
import 'utilities/helpers.dart';
import 'utilities/utility_export.dart';

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
    this.baseUrl,
    this.path, {
    BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper,
  }) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      path,
      configuration: configuration,
    );
  }

  /// Default Constructor but with initialization.
  ///
  /// [baseUrl] is the base url of the wordpress site.
  /// [path] is the path of the url appended to your REST API.
  /// [bootstrapper] is a builder method for initializing the client.
  ///
  WordpressClient.initialize(
    this.baseUrl,
    this.path, {
    BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper,
  }) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      path,
      configuration: configuration,
    );

    Timer.run(initialize);
  }

  late final InternalRequester _requester;

  /// Base url supplied through constructor.
  final String baseUrl;

  /// Base url path supplied through constructor.
  final String path;

  /// Returns true if this instance of [WordpressClient] is running in debug mode.
  ///
  /// i.e., [LogInterceptor] of [Dio] is attached to [Dio] instance which prints every request & response to console.
  bool get isDebugMode => _requester._isDebugMode;

  /// Returns true if we have synchronized mode enabled.
  ///
  /// i.e., Only a single request is allowed at a time.
  bool get isSynchronizedMode => _requester._synchronized;

  /// Combined url of [baseUrl] and [path]
  String get requestUrl => parseUrl(baseUrl, path);

  /// Stores data on how to decode & encode responses.
  final TypeMap _typeMap = TypeMap();

  /// Request Base Url.
  ///
  /// Basically, [baseUrl] + [path]
  String get requestBaseUrl => baseUrl;

  /// The current user interface.
  ///
  /// Provides functionality to manipulate current authorized user.
  ///
  /// Available Operations:
  /// - Retrive (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  MeInterface get me => getInterface<MeInterface>('me');

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
  PostsInterface get posts => getInterface<PostsInterface>('posts');

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
  CategoryInterface get categories =>
      getInterface<CategoryInterface>('categories');

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
  CommentInterface get comments => getInterface<CommentInterface>('comments');

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
  MediaInterface get media => getInterface<MediaInterface>('media');

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
  TagInterface get tags => getInterface<TagInterface>('tags');

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
  UsersInterface get users => getInterface<UsersInterface>('users');

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
    initInterface<MeInterface, User>(
      interface: MeInterface(),
      key: 'me',
      responseDecoder: User.fromJson,
      responseEncoder: (dynamic user) => (user as User).toJson(),
    );

    initInterface<PostsInterface, Post>(
      interface: PostsInterface(),
      key: 'posts',
      responseDecoder: Post.fromJson,
      responseEncoder: (dynamic post) => (post as Post).toJson(),
    );

    initInterface<CategoryInterface, Category>(
      interface: CategoryInterface(),
      key: 'categories',
      responseDecoder: Category.fromJson,
      responseEncoder: (dynamic category) => (category as Category).toJson(),
    );

    initInterface<CommentInterface, Comment>(
      interface: CommentInterface(),
      key: 'comments',
      responseDecoder: Comment.fromJson,
      responseEncoder: (dynamic comment) => (comment as Comment).toJson(),
    );

    initInterface<MediaInterface, Media>(
      interface: MediaInterface(),
      key: 'media',
      responseDecoder: Media.fromJson,
      responseEncoder: (dynamic media) => (media as Media).toJson(),
    );

    initInterface<TagInterface, Tag>(
      interface: TagInterface(),
      key: 'tags',
      responseDecoder: Tag.fromJson,
      responseEncoder: (dynamic tag) => (tag as Tag).toJson(),
    );

    initInterface<UsersInterface, User>(
      interface: UsersInterface(),
      key: 'users',
      responseDecoder: User.fromJson,
      responseEncoder: (dynamic user) => (user as User).toJson(),
    );
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IInterface] abstract class, which provides internal requester instance and other functions.
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
  void initInterface<T extends IInterface, E>({
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
  T getInterface<T extends IInterface>([String? key]) {
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
  void reconfigureRequester(
    BootstrapConfiguration Function(BootstrapBuilder) bootstrapper,
  ) {
    return _requester.configure(bootstrapper(BootstrapBuilder()));
  }
}

/// The base of all request interfaces.
/// You must extend from this interface to define custom requests.
abstract class IInterface {
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
