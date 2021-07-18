import 'package:wordpress_client/src/utilities/pair.dart';

class ResponseContainer<T> {
  final T value;
  final int responseCode;
  final List<Pair<String, String>> responseHeaders;
  final Duration duration;
  final String message;

  bool get status => responseCode != null && responseCode == 200;

  int get totalPagesCount => responseHeaders != null && responseHeaders.isNotEmpty
      ? int.tryParse(responseHeaders.singleWhere((element) => element.key == 'x-wp-totalpages')?.value ?? '0') ?? 0
      : 0;

  int get totalPostsCount => responseHeaders != null && responseHeaders.isNotEmpty
      ? int.tryParse(responseHeaders.singleWhere((element) => element.key == 'x-wp-total')?.value ?? '0') ?? 0
      : 0;

  ResponseContainer(
    this.value, {
    this.responseCode,
    this.responseHeaders,
    this.duration,
    this.message,
  });

  ResponseContainer.success(
    this.value, {
    this.responseCode = 200,
    this.responseHeaders,
    this.duration,
    this.message,
  });

  ResponseContainer.failed(
    this.value, {
    this.responseCode,
    this.responseHeaders,
    this.duration,
    this.message,
  });
}
