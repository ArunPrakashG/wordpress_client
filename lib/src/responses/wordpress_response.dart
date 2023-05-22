import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';

@immutable
class WordpressResponse<T> {
  const WordpressResponse(
    this.data, {
    required this.responseCode,
    required this.responseHeaders,
    this.requestDuration,
    this.message,
  });

  const WordpressResponse.success(
    this.data, {
    this.responseCode = 200,
    required this.responseHeaders,
    this.requestDuration,
    this.message,
  });

  const WordpressResponse.failed(
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

  @override
  bool operator ==(covariant WordpressResponse<T> other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.data == data &&
        other.responseCode == responseCode &&
        mapEquals(other.responseHeaders, responseHeaders) &&
        other.requestDuration == requestDuration &&
        other.message == message;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        responseCode.hashCode ^
        responseHeaders.hashCode ^
        requestDuration.hashCode ^
        message.hashCode;
  }
}
