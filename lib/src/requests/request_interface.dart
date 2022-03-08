// ignore: one_member_abstracts
import 'request_content.dart';

/// Base class of all requests.
// ignore: one_member_abstracts
abstract class IRequest {
  /// Builds the request content.
  ///
  /// This method is invoked when the request is ready to be send.
  ///
  /// Request body, headers and other request properties are set by appending on to request content properties.
  void build(RequestContent requestContent);
}
