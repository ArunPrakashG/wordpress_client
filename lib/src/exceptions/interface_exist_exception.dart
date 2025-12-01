import '../enums.dart';
import '../utilities/helpers.dart';
import 'wordpress_exception_base.dart';

class InterfaceExistException<T> implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.interfaceExist;

  @override
  String? get message => 'An interface with ${typeOf<T>()} already exist!';
}
