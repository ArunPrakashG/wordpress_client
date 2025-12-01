import '../enums.dart';
import 'wordpress_exception_base.dart';

class NullReferenceException extends WordpressException {
  NullReferenceException(String message)
      : super(ErrorType.nullReference, message);
}
