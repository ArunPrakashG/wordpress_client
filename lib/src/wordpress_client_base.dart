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
import 'library_exports.dart';
import 'request_executor_base.dart';
import 'utilities/codable_map/codable_map.dart';
import 'utilities/helpers.dart';

part 'internal_requester.dart';
part 'requests/request_interface_base.dart';

/// The main class for interacting with the WordPress REST API.
///
/// This class provides methods to initialize the client, register interfaces,
/// and perform various operations on WordPress resources.
///
/// Example usage:
/// ```dart
/// final client = WordpressClient(
///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
///   bootstrapper: (builder) => builder
///     .withDefaultAuthorization(
///       WordpressAuth.applicationPassword('username', 'app_password')
///     )
///     .build(),
/// );
///
/// // Get posts
/// final posts = await client.posts.list();
/// ```
final class WordpressClient implements IDisposable {
  /// Creates a new [WordpressClient] instance.
  ///
  /// [baseUrl] is the base URL of the WordPress site's REST API.
  /// [bootstrapper] is an optional function to configure the client.
  ///
  /// Throws an [ArgumentError] if the provided URL is invalid.
  ///
  /// Example:
  /// ```dart
  /// final client = WordpressClient(
  ///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  ///   bootstrapper: (builder) => builder
  ///     .withDefaultAuthorization(
  ///       AppPasswordAuth('username', 'app_password')
  ///     )
  ///     .build(),
  /// );
  /// ```
  factory WordpressClient({
    required Uri baseUrl,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    if (!baseUrl.isAbsolute) {
      throw ArgumentError(
        'The provided url is relative. Base URLs should always be an absolute URL.',
        'baseUrl',
      );
    }

    if (!isValidPortNumber(baseUrl.port)) {
      throw ArgumentError(
        'The provided port number is invalid. Port numbers should be between 1 and 65535.',
        'baseUrl',
      );
    }

    if (!isValidRestApiUrl(baseUrl)) {
      throw ArgumentError(
        'The provided url is invalid. The REST API path should be appended to the base URL.',
        'baseUrl',
      );
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    final typeMap = CodableMap();
    final interfaces = <InterfaceKey<dynamic>, dynamic>{};
    final client = Dio();
    final middlewares = configuration.middlewares ?? <IWordpressMiddleware>[];

    return WordpressClient._(
      InternalRequester.configure(
        baseUrl,
        client,
        configuration,
      ),
      typeMap,
      interfaces,
      middlewares,
    );
  }

  /// Creates a [WordpressClient] instance without a base URL.
  ///
  /// This constructor is useful when you don't know the base URL at initialization time.
  /// Note that operations requiring the base URL will throw exceptions until [reconfigure] is called with a valid URL.
  ///
  /// [instance] is an optional Dio instance to use for HTTP requests.
  /// [bootstrapper] is an optional function to configure the client.
  ///
  /// Example:
  /// ```dart
  /// final client = WordpressClient.generic(
  ///   bootstrapper: (builder) => builder
  ///     .withDefaultAuthorization(
  ///       AppPasswordAuth('username', 'app_password')
  ///     )
  ///     .build(),
  /// );
  ///
  /// // Later, when you know the base URL:
  /// client.reconfigure(baseUri: Uri.parse('https://example.com/wp-json/wp/v2'));
  /// ```
  factory WordpressClient.generic({
    Dio? instance,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    final typeMap = CodableMap();
    final interfaces = <InterfaceKey<dynamic>, dynamic>{};
    final client = instance ?? Dio();
    final middlewares = configuration.middlewares ?? <IWordpressMiddleware>[];

    return WordpressClient._(
      InternalRequester.configure(
        null,
        client,
        configuration,
      ),
      typeMap,
      interfaces,
      middlewares,
    );
  }

  WordpressClient._(
    this._requester,
    this._typeMap,
    this._interfaces,
    this._middlewares,
  ) {
    _initialize();
  }

  /// Creates a [WordpressClient] instance with a custom Dio instance.
  ///
  /// This constructor is useful when you need to customize the Dio instance used for HTTP requests.
  ///
  /// [baseUrl] is the base URL of the WordPress site's REST API.
  /// [instance] is the custom Dio instance to use.
  /// [bootstrapper] is an optional function to configure the client.
  ///
  /// Example:
  /// ```dart
  /// final dio = Dio()..interceptors.add(CustomInterceptor());
  /// final client = WordpressClient.fromDioInstance(
  ///   baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  ///   instance: dio,
  ///   bootstrapper: (builder) => builder
  ///     .withDefaultAuthorization(
  ///       AppPasswordAuth('username', 'app_password')
  ///     )
  ///     .build(),
  /// );
  /// ```
  factory WordpressClient.fromDioInstance({
    required Uri baseUrl,
    required Dio instance,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    if (!baseUrl.isAbsolute) {
      throw ArgumentError(
        'The provided url is relative. Base URLs should always be an absolute URL.',
        'baseUrl',
      );
    }

    if (!isValidPortNumber(baseUrl.port)) {
      throw ArgumentError(
        'The provided port number is invalid. Port numbers should be between 1 and 65535.',
        'baseUrl',
      );
    }

    if (!isValidRestApiUrl(baseUrl)) {
      throw ArgumentError(
        'The provided url is invalid. The REST API path should be appended to the base URL.',
        'baseUrl',
      );
    }

    var configuration = const BootstrapConfiguration();

    if (bootstrapper != null) {
      configuration = bootstrapper(BootstrapBuilder());
    }

    final typeMap = CodableMap();
    final interfaces = <InterfaceKey<dynamic>, dynamic>{};
    final middlewares = configuration.middlewares ?? <IWordpressMiddleware>[];

    return WordpressClient._(
      InternalRequester.configure(
        baseUrl,
        instance,
        configuration,
      ),
      typeMap,
      interfaces,
      middlewares,
    );
  }

  /// Deprecated constructor. Use [WordpressClient] instead.
  @Deprecated(
    'Use WordpressClient() constructor instead. This is no longer required.',
  )
  factory WordpressClient.initialize({
    required Uri baseUrl,
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
  }) {
    return WordpressClient(
      baseUrl: baseUrl,
      bootstrapper: bootstrapper,
    );
  }

  final InternalRequester _requester;
  final CodableMap _typeMap;
  bool _isDisposed = false;
  final Map<InterfaceKey<dynamic>, dynamic> _interfaces;
  final List<IWordpressMiddleware> _middlewares;
  WordpressDiscovery? _discovery;
  bool _hasInitialized = false;

  /// The base URL of this WordPress REST API instance.
  Uri get baseUrl => _requester.baseUrl;

  /// The path component of the base URL.
  String get path => baseUrl.path;

  /// Indicates whether this [WordpressClient] instance has been disposed.
  bool get disposed => _isDisposed;

  /// Returns true if this instance is running in debug mode (i.e., with Dio's LogInterceptor attached).
  bool get isDebugMode => _requester._isDebugMode;

  /// Returns true if a valid default authorization is set for all requests.
  bool get hasValidDefaultAuthorization {
    if (_requester._defaultAuthorization == null) {
      return false;
    }

    return _requester._defaultAuthorization!.isValidAuth;
  }

  /// Returns true if the WordPress site discovery process has been completed.
  bool get discoveryCompleted => _discovery != null;

  /// Interface for operations on the current authorized user.
  ///
  /// Available operations:
  /// - Retrieve (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final currentUser = await client.me.retrieve(RetrieveMeRequest());
  /// print(currentUser.name);
  /// ```
  MeInterface get me => get<MeInterface>('me');

  /// Interface for operations on posts.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final posts = await client.posts.list(ListPostsRequest());
  /// for (final post in posts) {
  ///   print(post.title);
  /// }
  /// ```
  PostsInterface get posts => get<PostsInterface>('posts');

  /// Interface for operations on pages.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final pages = await client.pages.list(ListPagesRequest());
  /// for (final page in pages) {
  ///   print(page.title);
  /// }
  /// ```
  PagesInterface get pages => get<PagesInterface>('pages');

  /// Interface for operations on categories.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final categories = await client.categories.list(ListCategoriesRequest());
  /// for (final category in categories) {
  ///   print(category.name);
  /// }
  /// ```
  CategoryInterface get categories => get<CategoryInterface>('categories');

  /// Interface for operations on comments.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final comments = await client.comments.list(ListCommentsRequest());
  /// for (final comment in comments) {
  ///   print(comment.content);
  /// }
  /// ```
  CommentInterface get comments => get<CommentInterface>('comments');

  /// Interface for operations on media.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final mediaItems = await client.media.list(ListMediaRequest());
  /// for (final item in mediaItems) {
  ///   print(item.sourceUrl);
  /// }
  /// ```
  MediaInterface get media => get<MediaInterface>('media');

  /// Interface for operations on tags.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final tags = await client.tags.list(ListTagsRequest());
  /// for (final tag in tags) {
  ///   print(tag.name);
  /// }
  /// ```
  TagInterface get tags => get<TagInterface>('tags');

  /// Interface for operations on users.
  ///
  /// Available operations:
  /// - List
  /// - Retrieve
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final users = await client.users.list(ListUsersRequest());
  /// for (final user in users) {
  ///   print(user.name);
  /// }
  /// ```
  UsersInterface get users => get<UsersInterface>('users');

  /// Interface for search operations.
  ///
  /// Available operations:
  /// - List
  ///
  /// Example:
  /// ```dart
  /// final searchResults = await client.search.list(ListSearchRequest(search: 'WordPress'));
  /// for (final result in searchResults) {
  ///   print(result.title);
  /// }
  /// ```
  SearchInterface get search => get<SearchInterface>('search');

  /// Interface for operations on application passwords.
  ///
  /// Available operations:
  /// - List (Requires Authorization)
  /// - Create (Requires Authorization)
  /// - Update (Requires Authorization)
  /// - Retrieve (Requires Authorization)
  /// - Delete (Requires Authorization)
  ///
  /// Example:
  /// ```dart
  /// final appPasswords = await client.applicationPasswords.list(ListApplicationPasswordsRequest());
  /// for (final password in appPasswords) {
  ///   print(password.name);
  /// }
  /// ```
  ApplicationPasswordsInterface get applicationPasswords =>
      get<ApplicationPasswordsInterface>('application-passwords');

  /// Indicates whether the client has been initialized successfully.
  bool get isReady => _hasInitialized && _requester.hasBaseURL;

  /// Returns the WordPress site discovery information.
  ///
  /// Throws a [DiscoveryPendingException] if discovery hasn't been performed yet.
  WordpressDiscovery get discovery {
    if (_discovery == null) {
      throw DiscoveryPendingException();
    }

    return _discovery!;
  }

  /// Checks if the provided URL is valid.
  ///
  /// Returns true if the URL is absolute and has a valid port number.
  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return false;
    }

    if (!uri.isAbsolute) {
      return false;
    }

    if (!isValidPortNumber(uri.port)) {
      return false;
    }

    return true;
  }

  /// Initializes all the built-in interfaces and other services.
  void _initialize() {
    if (_hasInitialized) {
      return;
    }

    _registerInternalInterfaces();
    _hasInitialized = true;
  }

  @Deprecated(
    'Calling this is no longer required. We are initializing from the constructor itself.',
  )
  void initialize() {
    // Hi! I really don't want to break anyone's code (again). So just leaving this here :P
    // Hope you are having a great day!
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

    reconfigure(
      bootstrapper: (builder) => builder.withMiddlewares(_middlewares).build(),
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

    reconfigure(
      bootstrapper: (builder) => builder.withMiddlewares(_middlewares).build(),
    );
  }

  /// Clears default authorization if exists.
  void clearDefaultAuthorization() => _requester._removeDefaultAuthorization();

  /// Called to reconfigure the client with new settings.
  ///
  /// The default builder will contain all the previous settings.
  ///
  /// Only the settings that have changed since will be updated.
  @Deprecated('Prefer `reconfigure` instead.')
  void reconfigureClient(
    BootstrapConfiguration Function(BootstrapBuilder builder) bootstrapper, {
    Uri? baseUri,
  }) {
    if (baseUri != null) {
      _requester._setBaseUrl(baseUri);
    }

    return _requester.configure(
      bootstrapper(
        BootstrapBuilder.fromConfiguration(
          _requester._configuration,
        ),
      ),
    );
  }

  /// Called to reconfigure the client with new settings.
  ///
  /// The default builder will contain all the previous settings.
  ///
  /// Only the settings that have changed since will be updated.
  void reconfigure({
    BootstrapConfiguration Function(BootstrapBuilder builder)? bootstrapper,
    Uri? baseUri,
  }) {
    if (baseUri != null) {
      _requester._setBaseUrl(baseUri);
    }

    if (bootstrapper != null) {
      _requester.configure(
        bootstrapper(
          BootstrapBuilder.fromConfiguration(
            _requester._configuration,
          ),
        ),
      );
    }
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
      WordpressClient(
        baseUrl: baseUri,
      ),
      (client) async {
        final response = await client.discover();

        if (!response) {
          throw DiscoveryFailedException();
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

    reconfigure(
      bootstrapper: (builder) => builder.withMiddlewares(_middlewares).build(),
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

    return guardAsync(
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
