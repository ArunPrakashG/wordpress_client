import 'dart:async';

import '../wordpress_client_base.dart';

/// The base of all custom requests.
/// extend from this interface on your custom request interfaces to get the internal requester client for all your requests.
abstract class IInterface {
  String get baseUrl => WordpressClient.requestBaseUrl;
  String get path => WordpressClient.requestPath;
  String get requestBaseWithPath => WordpressClient.requestBaseWithPath;

  /// The internal requester instance.
  ///
  /// This variable is assigned on init method automatically.
  late InternalRequester internalRequester;

  /// The interface key, this must be unique and will act as a unique identifier for this interface.
  late String? interfaceKey;

  bool hasInitilizedAlready = false;

  /// Gets the internal requester client by waiting for it be free.
  ///
  /// You can directly get [InternalRequester] with waiting by [internalRequester] variable.
  Future<InternalRequester> getInternalRequesterWhenFree() async {
    while (internalRequester.isBusy) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    return internalRequester;
  }

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
  FutureOr<void> init(InternalRequester requester, String? key) {
    if (!hasInitilizedAlready) {
      internalRequester = requester;
      interfaceKey = key;

      hasInitilizedAlready = true;
    }
  }
}
