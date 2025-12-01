import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import 'wordpress_error.dart';

@immutable

/// Represents a successful response from the WordPress REST API.
///
/// This class encapsulates the data and metadata returned by a successful API request.
/// It provides access to the response data, headers, and pagination information.
///
/// The generic type [T] represents the type of the response data.
///
/// For more information on WordPress REST API responses, see:
/// https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/#_envelope
final class WordpressSuccessResponse<T> extends WordpressResponse<T> {
  /// Creates a new [WordpressSuccessResponse] instance.
  ///
  /// [headers]: The response headers.
  /// [duration]: The time taken for the request to complete.
  /// [data]: The parsed response data.
  /// [rawData]: The raw response data.
  /// [requestHeaders]: The headers sent with the request.
  /// [code]: The HTTP status code (defaults to 200).
  /// [extra]: Additional metadata associated with the response.
  /// [message]: An optional message describing the response.
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

  /// The parsed response data.
  final T data;

  /// Returns the total number of pages available for the current query.
  ///
  /// This value is extracted from the 'X-WP-TotalPages' header.
  /// If the header is not present, it returns 0.
  ///
  /// For more information on pagination headers, see:
  /// https://developer.wordpress.org/rest-api/using-the-rest-api/pagination/
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

  /// Returns the total number of items available for the current query.
  ///
  /// This value is extracted from the 'X-WP-Total' header.
  /// If the header is not present, it returns 0.
  ///
  /// For more information on pagination headers, see:
  /// https://developer.wordpress.org/rest-api/using-the-rest-api/pagination/
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

/// Represents a failure response from the WordPress REST API.
///
/// This class encapsulates the error information returned by a failed API request.
/// It provides access to the error details, status code, and any additional metadata.
///
/// The generic type [T] represents the expected type of the response data had the request succeeded.
///
/// For more information on WordPress REST API error responses, see:
/// https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/#_envelope
final class WordpressFailureResponse<T> extends WordpressResponse<T> {
  /// Creates a new [WordpressFailureResponse] instance.
  ///
  /// [error]: The WordPress error object containing error details.
  /// [code]: The HTTP status code of the error response.
  /// [rawData]: The raw error response data.
  /// [headers]: The response headers (defaults to an empty map).
  /// [requestHeaders]: The headers sent with the request (defaults to an empty map).
  /// [extra]: Additional metadata associated with the error response.
  /// [duration]: The time taken for the request to complete (defaults to zero duration).
  /// [message]: An optional message describing the error.
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

  /// The WordPress error object containing detailed error information.
  final WordpressError? error;

  /// The exception that caused the failure, if available.
  Object? get exception => extra?['error'];

  /// The stack trace associated with the failure, if available.
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

/// Base class for WordPress REST API responses.
///
/// This abstract interface defines the common properties and methods
/// shared by both successful and failure responses.
///
/// The generic type [T] represents the type of the response data.
///
/// For more information on WordPress REST API responses, see:
/// https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/#_envelope
abstract interface class WordpressResponse<T> {
  /// Creates a new [WordpressResponse] instance.
  ///
  /// [code]: The HTTP status code of the response.
  /// [headers]: The response headers.
  /// [duration]: The time taken for the request to complete.
  /// [requestHeaders]: The headers sent with the request.
  /// [rawData]: The raw response data.
  /// [extra]: Additional metadata associated with the response.
  /// [message]: An optional message describing the response.
  const WordpressResponse({
    required this.code,
    required this.headers,
    required this.duration,
    required this.requestHeaders,
    required dynamic rawData,
    this.extra,
    this.message,
  }) : _rawData = rawData;

  /// The HTTP status code of the response.
  final int code;

  /// The response headers.
  final Map<String, dynamic> headers;

  /// The headers sent with the request.
  final Map<String, dynamic> requestHeaders;

  /// Additional metadata associated with the response.
  final Map<String, dynamic>? extra;

  /// The time taken for the request to complete.
  final Duration duration;

  /// An optional message describing the response.
  final String? message;

  /// The raw response data.
  final dynamic _rawData;

  /// Allows accessing raw response data using index notation.
  ///
  /// Throws a [NullReferenceException] if the raw data is null.
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
