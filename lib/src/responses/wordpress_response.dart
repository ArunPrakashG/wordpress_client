import '../utilities/helpers.dart';

class WordpressResponse<T> {
  WordpressResponse(
    this.data, {
    required this.responseCode,
    required this.responseHeaders,
    this.requestDuration,
    this.message,
  });

  WordpressResponse.success(
    this.data, {
    this.responseCode = 200,
    required this.responseHeaders,
    this.requestDuration,
    this.message,
  });

  WordpressResponse.failed(
    this.data, {
    this.responseCode = -1,
    this.responseHeaders = const <String, dynamic>{},
    this.requestDuration,
    this.message,
  });

  final T data;
  final int responseCode;
  final Map<String, dynamic> responseHeaders;
  final Duration? requestDuration;
  final String? message;

  bool get isSuccess => isInRange(responseCode, 200, 299);

  int get totalPagesCount => responseHeaders.isNotEmpty
      ? int.tryParse((responseHeaders['x-wp-totalpages'] as String?) ?? '0') ??
          0
      : 0;

  int get totalCount => responseHeaders.isNotEmpty
      ? int.tryParse((responseHeaders['x-wp-total'] as String?) ?? '0') ?? 0
      : 0;
}
