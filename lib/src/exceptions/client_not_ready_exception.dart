import '../enums.dart';
import 'wordpress_exception_base.dart';

class ClientNotReadyException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.clientNotReady;

  @override
  String? get message =>
      'Client has not been initialized. This could happen due to the Base URL not being set. If you had created the WordpressClient instance using `generic` constructor, please use `reconfigure` method to pass a Base URL.';
}
