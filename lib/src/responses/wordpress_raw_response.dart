import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/helpers.dart';
import 'wordpress_error.dart';

/// Represents a success response from the WordPress API.
typedef OnSuccess<T> = WordpressSuccessResponse<T> Function(
  WordpressRawResponse response,
);

/// Represents a failure response from the WordPress API.
typedef OnFailure<T> = WordpressFailureResponse<T> Function(
  WordpressRawResponse response,
);

/// Represents a raw response from the WordPress API.
@immutable
final class WordpressRawResponse {
  /// Creates a new [WordpressRawResponse] instance.
  const WordpressRawResponse({
    required this.data,
    required this.code,
    this.headers = const {},
    this.requestHeaders = const {},
    this.duration = Duration.zero,
    this.extra = const {},
    this.message,
  });

  /// The entire response body. Can be null.
  ///
  /// This is the raw response from the HTTP client.
  final dynamic data;

  /// The HTTP status code.
  final int code;

  /// The HTTP response headers.
  final Map<String, dynamic> headers;

  /// The HTTP request headers.
  final Map<String, dynamic> requestHeaders;

  /// The extra content passed with the request.
  final Map<String, dynamic> extra;

  /// The request duration.
  final Duration duration;

  /// The error message.
  final String? message;

  /// Returns the [RequestErrorType] for this response.
  RequestErrorType get errorType {
    if (isSuccessful) {
      return RequestErrorType.noError;
    }

    if (RequestErrorType.values.any((element) => -element.index == code)) {
      return RequestErrorType.values[-code];
    }

    return RequestErrorType.unknown;
  }

  /// Returns true if the given [code] is in between 200 to 399 range.
  bool get isSuccessful => isInRange(code, 200, 399);

  /// Returns true if the given [code] is not in between 200 to 399 range. A convenience method for `!isSuccessful`.
  bool get isFailure => !isSuccessful;

  /// Maps this instance to a [WordpressResponse] instance.
  ///
  /// The [decoder] is used to decode the [data] to the desired type.
  ///
  /// ```dart
  /// final response = await client.posts.listRaw(
  ///  PostsListRequest(),
  /// );
  ///
  /// final posts = response.asResponse<List<Post>>(
  ///  decoder: (data) => (data as Iterable<dynamic>).map((e) => Post.fromMap(e)).toList(),
  /// );
  /// ```
  ///
  /// The above example shows how to decode the response data to a list of [Post] instances.
  ///
  /// In case if the response is a failure, the [WordpressFailureResponse] instance is returned.
  ///
  /// This is a convenience method for the `map` method.
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
        extra: extra,
        requestHeaders: requestHeaders,
      );
    }

    return WordpressSuccessResponse<T>(
      data: decoder(data),
      code: code,
      headers: headers,
      requestHeaders: requestHeaders,
      extra: extra,
      duration: duration,
      message: message,
    );
  }

  /// Returns the field value for the given [key].
  ///
  /// The [transformer] is used to transform the value to the desired type.
  ///
  /// The [orElse] is used to return a default value if the field is not found.
  ///
  /// The [throwIfError] is used to throw an exception if the response is a failure.
  ///
  /// ```dart
  /// final response = await client.posts.listRaw(
  ///   PostsListRequest(),
  /// );
  ///
  /// final posts = response.getField<List<Post>>(
  ///   'data',
  ///   transformer: (data) => (data as Iterable<dynamic>).map((e) => Post.fromMap(e)).toList(),
  /// );
  /// ```
  T? getField<T>(
    String key, {
    bool throwIfError = false,
    T? Function(Object object)? transformer,
    T Function()? orElse,
  }) {
    if (isFailure) {
      if (throwIfError) {
        throw NullReferenceException('Response is a failure.');
      }

      return orElse?.call();
    }

    if (data is! Map) {
      if (throwIfError) {
        throw NullReferenceException('Response is not a map.');
      }

      return orElse?.call();
    }

    if (data[key] == null) {
      if (throwIfError) {
        throw NullReferenceException("Field '$key' not found.");
      }

      return orElse?.call();
    }

    return castOrElse<T>(
      data[key],
      transformer: transformer,
      orElse: orElse,
    );
  }

  /// Maps this instance to a [WordpressResponse] instance.
  ///
  /// The [onSuccess] is called if the response is a success.
  ///
  /// The [onFailure] is called if the response is a failure.
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
