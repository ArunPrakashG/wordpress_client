import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import 'wordpress_error.dart';

@immutable

/// Represents a successful response.
final class WordpressSuccessResponse<T> extends WordpressResponse<T> {
  const WordpressSuccessResponse({
    required super.headers,
    required super.duration,
    required this.data,
    required super.rawData,
    required super.requestHeaders,
    super.code = 200,
    super.extra,
    super.message,
  });

  final T data;

  int get totalPagesCount {
    if (headers.isEmpty) {
      return 0;
    }

    if (headers['x-wp-totalpages'] != null) {
      return int.tryParse(
        castOrElse(headers['x-wp-totalpages'], orElse: () => '0')!,
      )!;
    }

    if (headers['X-Wp-TotalPages'] != null) {
      return int.tryParse(
        castOrElse(headers['X-Wp-TotalPages'], orElse: () => '0')!,
      )!;
    }

    return 0;
  }

  int get totalCount {
    if (headers.isEmpty) {
      return 0;
    }

    if (headers['x-wp-total'] != null) {
      return int.tryParse(
        castOrElse(headers['x-wp-total'], orElse: () => '0')!,
      )!;
    }

    if (headers['X-Wp-Total'] != null) {
      return int.tryParse(
        castOrElse(headers['X-Wp-Total'], orElse: () => '0')!,
      )!;
    }

    return 0;
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
    required super.rawData,
    super.headers = const {},
    super.requestHeaders = const {},
    super.extra,
    super.duration = Duration.zero,
    super.message,
  });

  final WordpressError? error;

  Object? get exception => extra?['error'];
  StackTrace? get stackTrace => extra?['stackTrace'];

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
    required this.requestHeaders,
    required dynamic rawData,
    this.extra,
    this.message,
  }) : _rawData = rawData;

  final int code;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> requestHeaders;
  final Map<String, dynamic>? extra;
  final Duration duration;
  final String? message;
  final dynamic _rawData;

  dynamic operator [](dynamic key) {
    if (_rawData == null) {
      throw NullReferenceException('Response is null.');
    }

    return _rawData[key];
  }

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
