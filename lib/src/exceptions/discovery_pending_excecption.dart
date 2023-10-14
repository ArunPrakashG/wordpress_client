import '../../wordpress_client.dart';
import 'wordpress_exception_base.dart';

class DiscoveryPendingException implements WordpressException {
  @override
  ErrorType get errorType => ErrorType.discoveryPending;

  @override
  String? get message =>
      'Discovery is not yet initiated. Please call discover() to run the discovery process before accessing this property.';
}
