import '../enums.dart';
import '../utilities/helpers.dart';
import 'wordpress_exception_base.dart';

class InterfaceNotInitializedException<T> implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.interfaceNotInitialized;

  @override
  String? get message => 'Interface not initialized (${typeOf<T>()})';
}
