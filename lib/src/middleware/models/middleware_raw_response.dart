/// Represents a raw response from a middleware operation.
///
/// This class encapsulates various components of an HTTP response, including
/// status code, headers, body, and additional metadata.
final class MiddlewareRawResponse {
  /// Creates a new [MiddlewareRawResponse] instance.
  ///
  /// [statusCode] and [body] are required parameters, while [message], [headers],
  /// and [extra] are optional.
  ///
  /// Example:
  /// ```dart
  /// final response = MiddlewareRawResponse(
  ///   statusCode: 200,
  ///   body: {'data': 'example'},
  ///   headers: {'Content-Type': 'application/json'},
  ///   message: 'Success',
  /// );
  /// ```
  const MiddlewareRawResponse({
    required this.statusCode,
    required this.body,
    this.message,
    this.headers,
    this.extra,
  });

  /// Creates a default instance of [MiddlewareRawResponse] with a status code of -99
  /// and a null body.
  ///
  /// This can be used as a placeholder or for initialization purposes.
  ///
  /// Example:
  /// ```dart
  /// final defaultResponse = MiddlewareRawResponse.defaultInstance();
  /// print(defaultResponse.statusCode); // Outputs: -99
  /// ```
  factory MiddlewareRawResponse.defaultInstance() {
    return const MiddlewareRawResponse(statusCode: -99, body: null);
  }

  /// The HTTP status code of the response.
  final int statusCode;

  /// The headers of the HTTP response, if any.
  final Map<String, dynamic>? headers;

  /// Additional metadata or context information about the response.
  final Map<String, dynamic>? extra;

  /// The body of the HTTP response. Can be of any type.
  final dynamic body;

  /// An optional message associated with the response.
  final String? message;

  /// Indicates whether the response contains valid data.
  ///
  /// Returns true if the body is not null and the status code is in the 2xx range.
  ///
  /// Example:
  /// ```dart
  /// final response = MiddlewareRawResponse(statusCode: 200, body: {'key': 'value'});
  /// print(response.hasData); // Outputs: true
  /// ```
  bool get hasData => body != null && statusCode >= 200 && statusCode < 300;

  @override
  String toString() {
    return 'MiddlewareRawResponse(statusCode: $statusCode, headers: $headers, body: $body, message: $message, extra: $extra)';
  }
}
