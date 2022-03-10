import '../enums.dart';
import 'wordpress_exception_base.dart';

class ClientNotReadyException implements IWordpressException {
  @override
  ErrorType get errorType => ErrorType.clientNotReady;

  @override
  String? get message =>
      'Client is currently in the process of initializing Interfaces and internal processes.';
}
