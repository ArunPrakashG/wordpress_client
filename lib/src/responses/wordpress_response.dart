import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'wordpress_error.dart';

@immutable

/// Represents a successful response.
final class WordpressSuccessResponse<T> extends WordpressResponse<T> {
  const WordpressSuccessResponse({
    super.code = 200,
    required super.headers,
    required super.duration,
    required this.data,
    super.message,
  });

  final T data;

  int get totalPagesCount {
    if (headers.isEmpty || headers['x-wp-totalpages'] == null) {
      return 0;
    }

    return int.tryParse(headers['x-wp-totalpages'] as String) ?? 0;
  }

  int get totalCount {
    if (headers.isEmpty || headers['x-wp-total'] == null) {
      return 0;
    }

    return int.tryParse(headers['x-wp-total'] as String) ?? 0;
  }

  @override
  bool operator ==(covariant WordpressSuccessResponse<T> other) {
    if (identical(this, other)) {
      return true;
    }

    return other.data == data &&
        other.code == code &&
        other.headers == headers &&
        other.duration == duration &&
        other.message == message;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      code.hashCode ^
      headers.hashCode ^
      duration.hashCode ^
      message.hashCode;
}

@immutable

/// Represents a failure response.
final class WordpressFailureResponse<T> extends WordpressResponse<T> {
  const WordpressFailureResponse({
    required this.error,
    required super.code,
    super.headers = const {},
    super.duration = Duration.zero,
    super.message,
  });

  final WordpressError error;

  @override
  bool operator ==(covariant WordpressFailureResponse other) {
    if (identical(this, other)) {
      return true;
    }

    return other.error == error &&
        other.code == code &&
        other.headers == headers &&
        other.duration == duration &&
        other.message == message;
  }

  @override
  int get hashCode =>
      error.hashCode ^
      code.hashCode ^
      headers.hashCode ^
      duration.hashCode ^
      message.hashCode;
}

@immutable
abstract interface class WordpressResponse<T> {
  const WordpressResponse({
    required this.code,
    required this.headers,
    required this.duration,
    this.message,
  });

  final int code;
  final Map<String, dynamic> headers;
  final Duration duration;
  final String? message;

  @override
  bool operator ==(covariant WordpressResponse other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.code == code &&
        mapEquals(other.headers, headers) &&
        other.duration == duration &&
        other.message == message;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        headers.hashCode ^
        duration.hashCode ^
        message.hashCode;
  }

  @override
  String toString() {
    return 'WordpressResponse(code: $code, headers: $headers, duration: $duration, message: $message)';
  }
}
