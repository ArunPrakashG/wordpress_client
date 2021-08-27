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
import 'utilities/helpers.dart';

class WordpressClient {
  late InternalRequester _requester;

  /// Base url supplied through constructor.
  static String requestBaseUrl = '';

  /// Base url path supplied through constructor.
  static String requestPath = '';

  /// Combined url of [requestBaseUrl] and [requestPath]
  static String requestBaseWithPath = '';

  /// The current user interface.
  ///
  /// Requests will only work if you are authorized with valid credentials.
  MeInterface get me => _customInterfaces!['me'];

  PostsInterface get posts => _customInterfaces!['posts'];
  CategoryInterface get categories => _customInterfaces!['categories'];
  CommentInterface get comments => _customInterfaces!['comments'];
  MediaInterface get media => _customInterfaces!['media'];
  TagInterface get tags => _customInterfaces!['tags'];
  UsersInterface get users => _customInterfaces!['users'];

  Map<String, dynamic>? _customInterfaces;

  WordpressClient(String? baseUrl, String? path, {BootstrapConfiguration Function(BootstrapBuilder)? bootstrapper}) {
    if (isNullOrEmpty(baseUrl)) {
      throw NullReferenceException('Base URL is invalid.');
    }

    if (isNullOrEmpty(path)) {
      throw NullReferenceException('Path is invalid.');
    }

    requestBaseUrl = baseUrl!;
    requestPath = path!;
    requestBaseWithPath = parseUrl(baseUrl, path);
    _customInterfaces ??= {};

    _requester = InternalRequester(
      baseUrl,
      path,
      bootstrapper == null ? null : bootstrapper(BootstrapBuilder()),
    );

    _initInternalInterfaces();
  }

  void _initInternalInterfaces() async {
    await initInterface<MeInterface>(MeInterface(), 'me');
    await initInterface<PostsInterface>(PostsInterface(), 'posts');
    await initInterface<CategoryInterface>(CategoryInterface(), 'categories');
    await initInterface<CommentInterface>(CommentInterface(), 'comments');
    await initInterface<MediaInterface>(MediaInterface(), 'media');
    await initInterface<TagInterface>(TagInterface(), 'tags');
    await initInterface<UsersInterface>(UsersInterface(), 'users');
  }

  /// Called to initialize an interface.
  /// All interfaces inherit from [IInterface] abstract class, which provides internal requester instance and other functions.
  ///
  /// [key] must be unique to this instance of [WordpressClient] as this will be used to indentify the instance.
  ///
  /// [interface] is instance of interface type [T]
  ///
  /// Example usage:
  ///
  /// ```dart
  /// await client.initInterface<MyCustomInterface>(MyCustomInterface(), 'my_custom_interface');
  /// ```
  ///
  Future<void> initInterface<T extends IInterface>(T? interface, String? key) async {
    _customInterfaces ??= {};

    if (interface == null || isNullOrEmpty(key)) {
      throw InvalidInterfaceException();
    }

    if (_customInterfaces![key] != null) {
      throw InterfaceExistException('[$key] Interface already exists.');
    }

    await interface.init(_requester, key);
    _customInterfaces![key!] = interface;
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
    _customInterfaces ??= {};

    var interface;

    if (!isNullOrEmpty(key)) {
      interface = _customInterfaces![key];
    }

    interface ??= _customInterfaces!.values.singleWhere((element) => element is T);

    if (interface == null) {
      throw InterfaceDoNotExistException('The specified interface do not exist.');
    }

    if (!(interface as T).hasInitilizedAlready) {
      throw InterfaceNotInitializedException();
    }

    return interface;
  }

  void removeDefaultAuthorization() => _requester.removeDefaultAuthorization();

  void reconfigureRequester(BootstrapConfiguration Function(BootstrapBuilder) bootstrapper) => _requester.configure(bootstrapper(BootstrapBuilder()));
}
