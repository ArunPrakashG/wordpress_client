import '../enums.dart';
import 'wordpress_exception_base.dart';

class FileDoesntExistException extends WordpressException {
  const FileDoesntExistException(String message)
      : super(ErrorType.fileDoesntExist, message);
}
