import '../../wordpress_client.dart';
import 'wordpress_exception_base.dart';

class DiscoveryFailedException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.discoveryFailed;

  @override
  String? get message => 'Wordpress discovery failed.';
}
