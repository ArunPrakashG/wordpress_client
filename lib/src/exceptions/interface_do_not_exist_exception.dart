import '../enums.dart';
import 'wordpress_exception_base.dart';

class InterfaceDoNotExistException extends WordpressException {
  const InterfaceDoNotExistException(String message)
      : super(ErrorType.interfaceDoNotExist, message);
}
