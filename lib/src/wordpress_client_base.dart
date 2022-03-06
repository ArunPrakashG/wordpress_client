import 'dart:async';

import 'builders_import.dart';
import 'client_configuration.dart';
import 'exceptions/interface_do_not_exist_exception.dart';
import 'exceptions/interface_exist_exception.dart';
import 'exceptions/interface_not_initialized.dart';
import 'exceptions/invalid_interface_exception.dart';
import 'exceptions/null_reference_exception.dart';
import 'interface/category.dart';
import 'interface/comments.dart';
import 'interface/interface_base.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/posts.dart';
import 'interface/tags.dart';
import 'interface/users.dart';
import 'internal_requester.dart';
import 'responses/category_response.dart';
import 'type_map.dart';
import 'utilities/helpers.dart';

class WordpressClient {
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
      typeMap: _initTypeMap(TypeMap()),
      configuration: configuration,
    );

    _initInternalInterfaces();
  }

  late InternalRequester _requester;

  /// Base url supplied through constructor.
  static late String requestBaseUrl;

  /// Base url path supplied through constructor.
  static late String requestPath;

  /// Combined url of [requestBaseUrl] and [requestPath]
  static String requestBaseWithPath = '';

  /// The current user interface.
  ///
  /// Requests will only work if you are authorized with valid credentials.
  MeInterface get me => _customInterfaces['me'] as MeInterface;

  PostsInterface get posts => _customInterfaces['posts'] as PostsInterface;
  CategoryInterface get categories =>
      _customInterfaces['categories'] as CategoryInterface;
  CommentInterface get comments =>
      _customInterfaces['comments'] as CommentInterface;
  MediaInterface get media => _customInterfaces['media'] as MediaInterface;
  TagInterface get tags => _customInterfaces['tags'] as TagInterface;
  UsersInterface get users => _customInterfaces['users'] as UsersInterface;

  final Map<String, dynamic> _customInterfaces = <String, dynamic>{};

  // ignore: avoid_void_async
  Future<void> _initInternalInterfaces() async {
    await initInterface<MeInterface>(MeInterface(), 'me');
    await initInterface<PostsInterface>(PostsInterface(), 'posts');
    await initInterface<CategoryInterface>(CategoryInterface(), 'categories');
    await initInterface<CommentInterface>(CommentInterface(), 'comments');
    await initInterface<MediaInterface>(MediaInterface(), 'media');
    await initInterface<TagInterface>(TagInterface(), 'tags');
    await initInterface<UsersInterface>(UsersInterface(), 'users');
  }

  TypeMap _initTypeMap(TypeMap typeMap) {
    return typeMap
      ..addJsonPairForType<Category>(
        decoder: Category.fromJson,
        encoder: (dynamic category) => (category as Category).toJson(),
      );
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IInterface] abstract class, which provides internal requester instance and other functions.
  ///
  /// [key] must be unique to this instance of [WordpressClient] as this will be used to indentify the instance.
  ///
  /// [interface] is instance of interface type [T]
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
  /// await client.initInterface<MyCustomInterface>(MyCustomInterface(), 'my_custom_interface');
  /// ```
  ///
  Future<void> initInterface<T extends IInterface>(
    T? interface,
    String? key,
  ) async {
    if (interface == null || isNullOrEmpty(key)) {
      throw InvalidInterfaceException();
    }

    if (_customInterfaces[key] != null) {
      throw InterfaceExistException('[$key] Interface already exists.');
    }

    await interface.init(_requester, key);
    _customInterfaces[key!] = interface;
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
    if (!isNullOrEmpty(key) && _customInterfaces[key] != null) {
      return _customInterfaces[key] as T;
    }

    final interfacesOfType = _customInterfaces.values.whereType<T>();

    if (interfacesOfType.isEmpty) {
      throw InterfaceDoNotExistException(
          'The specified interface do not exist.');
    }

    final interface = interfacesOfType.first;

    if (!interface.hasInitilizedAlready) {
      throw InterfaceNotInitializedException();
    }

    return interface;
  }

  void removeDefaultAuthorization() => _requester.removeDefaultAuthorization();

  void reconfigureRequester(
          BootstrapConfiguration Function(BootstrapBuilder) bootstrapper) =>
      _requester.configure(bootstrapper(BootstrapBuilder()));
}
