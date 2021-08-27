import 'builders_import.dart';
import 'client_configuration.dart';
import 'exceptions/null_reference_exception.dart';
import 'internal_requester.dart';
import 'utilities/helpers.dart';
import 'interface/category.dart';
import 'interface/posts.dart';
import 'interface/comments.dart';
import 'interface/me.dart';
import 'interface/media.dart';
import 'interface/tags.dart';
import 'interface/users.dart';

late InternalRequester _requester;

/// The base of all custom requests.
/// extend from this interface on your custom request interfaces to get the internal requester client for all your requests.
abstract class IInterface {
  String get baseUrl => WordpressClient.requestBaseUrl;
  String get path => WordpressClient.requestPath;
  String get requestBaseWithPath => WordpressClient.requestBaseWithPath;

  /// Gets the internal requester client.
  /// [shouldWaitIfBusy] is used to identify if the function should wait while a request is currently in progress.
  ///
  /// If false, [InternalRequester] instance is returned immediately.
  Future<InternalRequester> getInternalRequester({bool shouldWaitIfBusy = false}) async {
    if (shouldWaitIfBusy) {
      while (_requester.isBusy) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    return _requester;
  }
}

class WordpressClient {
  /// Base url supplied through constructor.
  static String requestBaseUrl = '';

  /// Base url path supplied through constructor.
  static String requestPath = '';

  /// Combined url of [requestBaseUrl] and [requestPath]
  static String requestBaseWithPath = '';

  /// The current user interface.
  ///
  /// Requests will only work if you are authorized with valid credentials.
  late MeInterface me = MeInterface();

  /// The posts interface.
  late PostsInterface posts = PostsInterface();
  late CategoryInterface categories = CategoryInterface();
  late CommentInterface comments = CommentInterface();
  late MediaInterface media = MediaInterface();
  late TagInterface tags = TagInterface();
  late UsersInterface users = UsersInterface();

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

    _requester = InternalRequester(
      baseUrl,
      path,
      bootstrapper == null ? null : bootstrapper(BootstrapBuilder()),
    );
  }

  void removeDefaultAuthorization() => _requester.removeDefaultAuthorization();

  void reconfigureRequester(BootstrapConfiguration Function(BootstrapBuilder) bootstrapper) => _requester.configure(bootstrapper(BootstrapBuilder()));
}
