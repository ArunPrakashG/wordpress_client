part of 'wordpress_client_base.dart';

/// The base of all request interfaces.
/// You must extend from this interface to define custom requests.
abstract base class IRequestInterface {
  /// The internal requester instance.
  ///
  /// This variable is assigned on init method automatically.
  late final IRequestExecutor executor;

  /// The interface key, this must be unique and will act as a unique identifier for this interface.
  late final InterfaceKey<dynamic> interfaceKey;

  bool _hasInitilizedAlready = false;

  /// Gets the base url of the wordpress site.
  Uri get baseUrl => executor.baseUrl;

  /// This method is used to initialize the interface by passing [InternalRequester] instance from the core to the interface.
  ///
  /// This method is called only once in interface lifecycle.
  ///
  /// It should always call super init() if it is overriden like so `super.init(requester, key)`.
  /// Failing to call super init() method means [executor] variable will be null and therefore none of the requests will go through and throws exception.
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
  void _initInterface({
    required IRequestExecutor requester,
    required InterfaceKey<dynamic> key,
  }) {
    if (_hasInitilizedAlready) {
      return;
    }

    executor = requester;
    interfaceKey = key;
    _hasInitilizedAlready = true;
    onInit();
  }

  /// This method is called right after internal initialization process of the interface completes.
  void onInit() {}
}
