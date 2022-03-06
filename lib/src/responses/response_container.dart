class ResponseContainer<T> {
  ResponseContainer(
    this.value, {
    required this.responseCode,
    required this.responseHeaders,
    this.duration,
    this.message,
  });

  ResponseContainer.success(
    this.value, {
    this.responseCode = 200,
    required this.responseHeaders,
    this.duration,
    this.message,
  });

  ResponseContainer.failed(
    this.value, {
    this.responseCode = -1,
    this.responseHeaders = const <String, dynamic>{},
    this.duration,
    this.message,
  });

  final T value;
  final int responseCode;
  final Map<String, dynamic> responseHeaders;
  final Duration? duration;
  final String? message;

  bool get status => responseCode == 200;

  int get totalPagesCount => responseHeaders.isNotEmpty
      ? int.tryParse((responseHeaders['x-wp-totalpages'] as String?) ?? '0') ??
          0
      : 0;

  int get totalPostsCount => responseHeaders.isNotEmpty
      ? int.tryParse((responseHeaders['x-wp-total'] as String?) ?? '0') ?? 0
      : 0;
}
