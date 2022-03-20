// ignore: one_member_abstracts
// ignore_for_file: comment_references

import 'request_content.dart';

/// Base class of all requests.
// ignore: one_member_abstracts
abstract class IRequest {
  /// Builds the request content.
  ///
  /// This method is invoked when the request is ready to be send.
  ///
  /// Request body, headers and other request properties are set by appending on to request content properties.
  ///
  /// Consider using [addIfNotNull] extension method to add a value to a map if it is not null.
  ///
  /// It is not recommended to run functions which takes time to complete in the `build()` method. This can affect entire client performence as this method is invoked from a constructor.
  void build(RequestContent requestContent);
}
