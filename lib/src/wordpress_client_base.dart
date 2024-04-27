// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:path/path.dart';

import 'bootstrap_builder.dart';
import 'constants.dart';
import 'interface/application_passwords.dart';
import 'interface/category.dart';
import 'interface/comments.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/page.dart';
import 'interface/posts.dart';
import 'interface/search.dart';
import 'interface/tags.dart';
import 'interface/users.dart';
import 'interface_key.dart';
import 'internal_requester_base.dart';
import 'library_exports.dart';
import 'utilities/codable_map/codable_map.dart';
import 'utilities/helpers.dart';

part 'internal_requester.dart';
part 'requests/request_interface_base.dart';

/// The main class for [WordpressClient].
final class WordpressClient implements IDisposable {
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
  WordpressClient({
    required Uri baseUrl,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    if (!baseUrl.isAbsolute) {
      throw ArgumentError(
        'The provided url is relative. Base URLs should always be an absolute URL.',
        'baseUrl',
      );
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      configuration,
    );

    if (configuration.middlewares != null &&
        configuration.middlewares!.isNotEmpty) {
      _middlewares.addAll(configuration.middlewares!);
    }
  }

  /// Default Constructor but with initialization.
  ///
  /// [baseUrl] is the base url of the wordpress site.
  /// [path] is the path of the url appended to your REST API.
  /// [bootstrapper] is a builder method for initializing the client.
  ///
  WordpressClient.initialize({
    required Uri baseUrl,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    if (!baseUrl.isAbsolute) {
      throw ArgumentError(
        'The provided url is relative. Base URLs should always be an absolute URL.',
        'baseUrl',
      );
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    _requester = InternalRequester.configure(
      baseUrl,
      configuration,
    );

    if (configuration.middlewares != null &&
        configuration.middlewares!.isNotEmpty) {
      _middlewares.addAll(configuration.middlewares!);
    }

    initialize();
  }

  late final InternalRequester _requester;

  /// Base url supplied through constructor.
  Uri get baseUrl => _requester._baseUrl;

  /// Base url path.
  String get path => baseUrl.path;

  bool get disposed => _isDisposed;

  /// Returns true if this instance of [WordpressClient] is running in debug mode.
  ///
  /// i.e., [LogInterceptor] of [Dio] is attached to [Dio] instance which prints every request & response to console.
  bool get isDebugMode => _requester._isDebugMode;

  /// Returns true if we have valid default authorization which is to be used for all requests.
  bool get hasValidDefaultAuthorization =>
      _requester._defaultAuthorization != null &&
      _requester._defaultAuthorization!.isValidAuth;

  /// Stores data on how to decode & encode responses.
  final CodableMap _typeMap = CodableMap();
  bool _isDisposed = false;

  /// The current user interface.
  ///
  /// Provides functionality to manipulate current authorized user.
  ///
  /// Available Operations:
  /// - Retrive (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  MeInterface get me => get<MeInterface>('me');

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
  PostsInterface get posts => get<PostsInterface>('posts');

  /// The pages interface.
  ///
  /// Provides functionality to manipulate pages.
  ///
  /// Available Operations:
  /// - List
  /// - Retrive
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  PagesInterface get pages => get<PagesInterface>('pages');

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
  CategoryInterface get categories => get<CategoryInterface>('categories');

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
  CommentInterface get comments => get<CommentInterface>('comments');

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
  MediaInterface get media => get<MediaInterface>('media');

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
  TagInterface get tags => get<TagInterface>('tags');

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
  UsersInterface get users => get<UsersInterface>('users');

  /// The search interface.
  ///
  /// Provides functionality to search posts, terms, post-formats.
  ///
  /// Available Operations:
  /// - List
  ///
  SearchInterface get search => get<SearchInterface>('search');

  /// The application password interface.
  ///
  /// Provides functionality to list, create and delete application passwords.
  ///
  /// Available Operations:
  /// - List (Requires Authorization)
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Retrive (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  ApplicationPasswordsInterface get applicationPasswords =>
      get<ApplicationPasswordsInterface>('application-passwords');

  final _interfaces = <InterfaceKey<dynamic>, dynamic>{};
  final _middlewares = <IWordpressMiddleware>[];

  bool _hasInitialized = false;

  /// Status on if the client has been initialized successfully.
  ///
  /// This will be true if [initialize] method has been called and completed.
  bool get isReady => _hasInitialized;

  WordpressDiscovery get discovery {
    if (_discovery == null) {
      throw DiscoveryPendingException();
    }

    return _discovery!;
  }

  WordpressDiscovery? _discovery;

  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return false;
    }

    if (!uri.isAbsolute) {
      return false;
    }

    return true;
  }

  /// Initializes all the built in interfaces and other services
  ///
  /// This method should be called before any other method.
  void initialize() {
    if (_hasInitialized) {
      return;
    }

    _registerInternalInterfaces();
    _hasInitialized = true;
  }

  void _registerInternalInterfaces() {
    register<MeInterface, User>(
      interface: MeInterface(),
      key: 'me',
      decoder: (json) => User.fromJson(json),
      encoder: (dynamic user) => (user as User).toJson(),
    );

    register<PostsInterface, Post>(
      interface: PostsInterface(),
      key: 'posts',
      decoder: (json) => Post.fromJson(json),
      encoder: (dynamic post) => (post as Post).toJson(),
    );

    register<CategoryInterface, Category>(
      interface: CategoryInterface(),
      key: 'categories',
      decoder: Category.fromJson,
      encoder: (dynamic category) => (category as Category).toJson(),
    );

    register<CommentInterface, Comment>(
      interface: CommentInterface(),
      key: 'comments',
      decoder: (json) => Comment.fromJson(json),
      encoder: (dynamic comment) => (comment as Comment).toJson(),
    );

    register<MediaInterface, Media>(
      interface: MediaInterface(),
      key: 'media',
      decoder: (json) => Media.fromJson(json),
      encoder: (dynamic media) => (media as Media).toJson(),
    );

    register<TagInterface, Tag>(
      interface: TagInterface(),
      key: 'tags',
      decoder: (json) => Tag.fromJson(json),
      encoder: (dynamic tag) => (tag as Tag).toJson(),
    );

    register<UsersInterface, User>(
      interface: UsersInterface(),
      key: 'users',
      decoder: (json) => User.fromJson(json),
      encoder: (dynamic user) => (user as User).toJson(),
    );

    register<SearchInterface, Search>(
      interface: SearchInterface(),
      key: 'search',
      decoder: (json) => Search.fromJson(json),
      encoder: (dynamic search) => (search as Search).toJson(),
    );

    register<PagesInterface, Page>(
      interface: PagesInterface(),
      key: 'pages',
      decoder: (json) => Page.fromJson(json),
      encoder: (dynamic page) => (page as Page).toJson(),
    );

    register<ApplicationPasswordsInterface, ApplicationPassword>(
      interface: ApplicationPasswordsInterface(),
      key: 'application-passwords',
      decoder: (json) => ApplicationPassword.fromJson(json),
      encoder: (dynamic appPassword) =>
          (appPassword as ApplicationPassword).toJson(),
    );
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IRequestInterface] abstract class, which provides internal requester instance and other functions.
  ///
  /// [key] must be unique to this instance of [WordpressClient] as this will be used to indentify the instance & the response type used by the interface requests.
  ///
  /// [interface] is instance of interface type [T]
  ///
  /// [decoder] is a function that takes a json object and returns an instance of [T]
  ///
  /// [encoder] is a function that takes an instance of [T] and returns a json object
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
  /// - `pages`
  /// - `application-passwords`
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
  void register<T extends IRequestInterface, E>({
    required T interface,
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<E> decoder,
    String? key,
    bool overriteIfTypeExists = false,
  }) {
    final interfaceKey = InterfaceKey<T>(key);

    if (_interfaces[interfaceKey] != null) {
      throw InterfaceExistException<T>();
    }

    _registerResponseType<E>(
      decoder: decoder,
      encoder: encoder,
      overriteIfExists: overriteIfTypeExists,
    );

    interface._initInterface(
      requester: _requester,
      key: interfaceKey,
    );

    _interfaces[interfaceKey] = interface;
  }

  /// Checks if an interface with the given Type [T] and [key] exists.
  bool exists<T>([String? key]) {
    return _interfaces[InterfaceKey<T>(key)] != null;
  }

  /// Registers a type to be used in [WordpressClient] Responses.
  ///
  /// This is called automatically on [register], During initializing of an interface.
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
    _typeMap.addCodablePair<E>(
      decoder: decoder,
      encoder: encoder,
      overwrite: overriteIfExists,
    );
  }

  /// Gets an initialized interface.
  ///
  /// [key] parameter is optional. However, getting result by specifing key is faster.
  ///
  /// All custom interfaces must inherit from [IRequestInterface] interface.
  ///
  /// Calling this method without initializing the custom interface using `initCustomInterface<T>(...)` will result in `InterfaceNotInitializedException`
  ///
  /// Example usage:
  ///
  /// ```dart
  /// await client.getCustomInterface<MyCustomInterface>().create((p1) => p1.build());
  /// ```
  ///
  T get<T extends IRequestInterface>([String? key]) {
    if (!isReady) {
      throw ClientNotReadyException();
    }

    final interfaceKey = InterfaceKey<T>(key);

    if (exists<T>(key)) {
      return _interfaces[interfaceKey] as T;
    }

    final interfacesOfType = _interfaces.values.whereType<T>();

    if (interfacesOfType.isEmpty) {
      throw InterfaceDoNotExistException(
        'The specified interface do not exist. (${typeOf<T>()}_$key)',
      );
    }

    final interface = interfacesOfType.first;

    if (!interface._hasInitilizedAlready) {
      throw InterfaceNotInitializedException<T>();
    }

    return interface;
  }

  void registerMiddleware(IWordpressMiddleware middleware) {
    if (_middlewares.contains(middleware)) {
      return;
    }

    unawaited(middleware.onLoad());

    _middlewares.add(middleware);

    reconfigureClient(
      (builder) => builder.withMiddlewares(_middlewares).build(),
    );
  }

  void removeMiddleware(String name) {
    if (!_middlewares.any((element) => element.name == name)) {
      return;
    }

    final middleware =
        _middlewares.firstWhere((element) => element.name == name);

    unawaited(middleware.onUnload());
    _middlewares.remove(middleware);

    reconfigureClient(
      (builder) => builder.withMiddlewares(_middlewares).build(),
    );
  }

  /// Clears default authorization if exists.
  void clearDefaultAuthorization() => _requester._removeDefaultAuthorization();

  /// Called to reconfigure the client with new settings.
  ///
  /// The default builder will contain all the previous settings.
  ///
  /// Only the settings that have changed since will be updated.
  void reconfigureClient(
    BootstrapConfiguration Function(BootstrapBuilder builder) bootstrapper,
  ) {
    return _requester.configure(
      bootstrapper(
        BootstrapBuilder.fromConfiguration(
          _requester._configuration,
        ),
      ),
    );
  }

  /// Fetches the discovery URL of the associated wordpress site and caches the response and returns the status as a boolean.
  ///
  /// The response object may allocate a decent amount of memory, it may be possible you wish to deallocate it.
  ///
  /// In that case, call `clearDiscoveryCache()` method to clear the cached discovery data.
  Future<bool> discover() async {
    if (_discovery != null) {
      return true;
    }

    final response = await _requester.discover();

    return response.map(
      onSuccess: (response) {
        _discovery = response.data;
        return _discovery != null;
      },
      onFailure: (response) {
        return false;
      },
    )!;
  }

  static Future<WordpressDiscovery> discoverAndClose(Uri baseUri) async {
    if (!isValidUrl(baseUri.toString())) {
      throw ArgumentError(
        'The provided url is invalid. Base URLs should always be an absolute URL.',
      );
    }

    return using(
      WordpressClient.initialize(
        baseUrl: baseUri,
      ),
      (client) async {
        final response = await client.discover();

        if (!response) {
          throw Exception('Failed to discover the site.');
        }

        return client.discovery;
      },
    );
  }

  /// Clears the stored discovery cache
  void clearDiscoveryCache() => _discovery = null;

  void clearMiddlewares() {
    for (final middleware in _middlewares) {
      unawaited(middleware.onUnload());
    }

    _middlewares.clear();

    reconfigureClient(
      (builder) => builder.withMiddlewares(_middlewares).build(),
    );
  }

  static Future<bool> isWordpressSite(Uri uri) async {
    if (!uri.isAbsolute) {
      throw ArgumentError(
        'The provided url is invalid. Base URLs should always be an absolute URL.',
        'uri',
      );
    }

    // Check if the url contains other path than the base
    if (uri.pathSegments.length > 1) {
      throw ArgumentError(
        'The provided url appears to be invalid. Remove any extra path segments from the URL.',
        'uri',
      );
    }

    return executeGuarded(
      function: () async {
        final client = Dio();

        final response = await client.getUri<String>(
          uri,
          options: Options(
            followRedirects: true,
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

        if (response.statusCode != 200) {
          client.close(force: true);
          return false;
        }

        final html = response.data ?? '';
        final headers = response.headers.map.map(
          (key, value) => MapEntry(key, value.join(', ')),
        );

        client.close(force: true);
        if (headers['X-Powered-By'] != null) {
          return headers['X-Powered-By']!.contains('WordPress');
        }

        if (headers['x-powered-by'] != null) {
          return headers['x-powered-by']!.contains('WordPress');
        }

        if (html.contains('wp-content')) {
          return true;
        }

        return false;
      },
      onError: (_, __) async {
        return false;
      },
    );
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    clearDefaultAuthorization();
    clearDiscoveryCache();
    clearMiddlewares();
    _typeMap.clear();
    _isDisposed = true;
  }
}
