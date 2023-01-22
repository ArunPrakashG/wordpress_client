import '../utilities/helpers.dart';

class WordpressResponse<T> {
  const WordpressResponse._(
    this.data, {
    required this.responseCode,
    required this.responseHeaders,
    this.requestDuration = Duration.zero,
    this.message,
  });

  factory WordpressResponse.success({
    required T responseData,
    required Map<String, dynamic> headers,
    int responseCode = 200,
    Duration duration = Duration.zero,
    String? message,
  }) {
    return WordpressResponse._(
      responseData,
      responseCode: responseCode,
      responseHeaders: headers,
      requestDuration: duration,
      message: message,
    );
  }

  factory WordpressResponse.failed({
    T? responseData,
    Map<String, dynamic> headers = const <String, dynamic>{},
    int responseCode = -1,
    Duration duration = Duration.zero,
    String? message,
  }) {
    return WordpressResponse._(
      responseData,
      responseCode: responseCode,
      responseHeaders: headers,
      requestDuration: duration,
      message: message,
    );
  }

  final T? data;
  final int responseCode;
  final Map<String, dynamic> responseHeaders;
  final Duration requestDuration;
  final String? message;

  bool get isSuccess => isInRange(responseCode, 200, 299);

  int get totalPagesCount {
    if (responseHeaders.isEmpty || responseHeaders['x-wp-totalpages'] == null) {
      return 0;
    }

    final totalPagesHeaderValue = responseHeaders['x-wp-totalpages'] as String;
    return int.tryParse(totalPagesHeaderValue)!;
  }

  int get totalCount {
    if (responseHeaders.isEmpty || responseHeaders['x-wp-total'] == null) {
      return 0;
    }

    final totalHeaderValue = responseHeaders['x-wp-total'] as String;
    return int.tryParse(totalHeaderValue)!;
  }
}
