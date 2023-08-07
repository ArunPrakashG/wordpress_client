import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/helpers.dart';
import 'wordpress_error.dart';

typedef OnSuccess<T> = WordpressSuccessResponse<T> Function(
  WordpressRawResponse response,
);

typedef OnFailure<T> = WordpressFailureResponse<T> Function(
  WordpressRawResponse response,
);

@immutable
final class WordpressRawResponse {
  const WordpressRawResponse({
    required this.data,
    required this.code,
    this.headers = const {},
    this.duration = Duration.zero,
    this.extra = const {},
    this.message,
  });

  final dynamic data;
  final int code;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> extra;
  final Duration duration;
  final String? message;

  bool get isSuccessful => isInRange(code, 200, 399);
  bool get isFailure => !isSuccessful;

  /// Returns a new [WordpressResponse] instance with the given [decoder].
  WordpressResponse<T> asResponse<T>({
    required T Function(dynamic data) decoder,
  }) {
    if (isFailure) {
      return WordpressFailureResponse(
        error: WordpressError.fromMap(data),
        code: code,
        headers: headers,
        duration: duration,
        message: message,
      );
    }

    return WordpressSuccessResponse<T>(
      data: decoder(data),
      code: code,
      headers: headers,
      duration: duration,
      message: message,
    );
  }

  /// Maps this instance to a [WordpressResponse] instance.
  WordpressResponse<T> map<T>({
    required OnSuccess<T> onSuccess,
    required OnFailure<T> onFailure,
  }) {
    if (isFailure) {
      return onFailure(this);
    }

    return onSuccess(this);
  }

  @override
  bool operator ==(covariant WordpressRawResponse other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.data == data &&
        other.code == code &&
        mapEquals(other.headers, headers) &&
        other.duration == duration &&
        other.message == message;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        code.hashCode ^
        headers.hashCode ^
        duration.hashCode ^
        message.hashCode;
  }
}
