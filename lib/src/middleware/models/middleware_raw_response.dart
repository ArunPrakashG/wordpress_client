final class MiddlewareRawResponse {
  const MiddlewareRawResponse({
    required this.statusCode,
    required this.body,
    this.headers,
    this.extra,
  });

  factory MiddlewareRawResponse.defaultInstance() {
    return const MiddlewareRawResponse(statusCode: -99, body: null);
  }

  final int statusCode;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? extra;
  final dynamic body;

  bool get hasData => body != null && statusCode >= 200 && statusCode < 300;

  @override
  String toString() {
    return 'MiddlewareRawResponse(statusCode: $statusCode, headers: $headers, body: $body)';
  }
}
