import '../enums.dart';
import 'wordpress_exception_base.dart';

class RequestUriParsingFailedException extends WordpressException {
  RequestUriParsingFailedException(String message)
      : super(ErrorType.requestUriParsingFailed, message);
}
