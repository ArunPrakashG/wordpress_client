import '../enums.dart';
import '../utilities/helpers.dart';
import 'wordpress_exception_base.dart';

class InvalidInterfaceException<T> implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.invalidInterface;

  @override
  String? get message => 'Invalid interface type: ${typeOf<T>()}';
}
