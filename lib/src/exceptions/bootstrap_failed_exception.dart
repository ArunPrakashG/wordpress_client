import '../enums.dart';
import 'wordpress_exception_base.dart';

class BootstrapFailedException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.bootstrapFailed;

  @override
  String? get message => 'Bootstrap process failed.';
}
