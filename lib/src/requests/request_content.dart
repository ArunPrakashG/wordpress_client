// ignore_for_file: comment_references

import '../enums.dart';

/// This class acts as a middleman between the request interface & and the request build method.
///
/// Properties [headers], [queryParameters], [body] are [Map]s. You cannot directly assign a new map to these. You will have to append to them.
///
/// Consider using [addIfNotNull] extension method to add a value to a map if it is not null.
class RequestContent {
  RequestContent()
      : body = <String, dynamic>{},
        headers = <String, String>{},
        queryParameters = <String, String>{};

  /// The headers to be passed with this request.
  final Map<String, String> headers;

  /// The query parameters to be passed with this request.
  final Map<String, String> queryParameters;

  /// The body to be passed with this request.
  final Map<String, dynamic> body;

  /// The endpoint to use for this request
  ///
  /// This must be filled at the build method of the request.
  String endpoint = '';

  /// The path to use for this request
  ///
  /// This is optional. If path is null, it will default back to the path passed in [WordpressClient] constructor.
  String? path;

  /// The HTTP method to use for this request
  ///
  /// By default, this is set to [HttpMethod.get].
  HttpMethod method = HttpMethod.get;
}
