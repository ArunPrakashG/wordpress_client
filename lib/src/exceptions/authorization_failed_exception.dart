import '../enums.dart';
import 'wordpress_exception_base.dart';

class AuthorizationFailedException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.authorizationFailed;

  @override
  String? get message => 'Authorization failed using this credentials.';
}
