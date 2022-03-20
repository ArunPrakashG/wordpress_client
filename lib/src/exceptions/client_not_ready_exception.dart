import '../enums.dart';
import 'wordpress_exception_base.dart';

class ClientNotReadyException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.clientNotReady;

  @override
  String? get message =>
      'Client has not been initialized. You might have forgotten to call `WordpressClient.initialize()` method or you please use the factory constructor `WordpressClient.initialize()` to initialize client with the constructor.';
}
