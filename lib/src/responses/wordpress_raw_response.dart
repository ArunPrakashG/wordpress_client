import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../constants.dart';
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

/// Represents a raw response from the WordPress REST API.
///
/// This class encapsulates the raw data returned by the WordPress REST API,
/// including the response body, status code, headers, and other metadata.
///
/// The WordPress REST API returns responses in JSON format. The structure
/// of the response varies depending on the endpoint and the nature of the request.
///
/// For more information on WordPress REST API responses, see:
/// https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/#_envelope
@immutable
final class WordpressRawResponse {
  /// Creates a new [WordpressRawResponse] instance.
  ///
  /// [data]: The entire response body. Can be null.
  /// [code]: The HTTP status code.
  /// [headers]: The HTTP response headers.
  /// [requestHeaders]: The HTTP request headers.
  /// [duration]: The request duration.
  /// [extra]: Additional metadata associated with the response.
  /// [message]: An optional message describing the response.
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
  /// This is the raw response from the HTTP client, typically in JSON format.
  /// The structure of this data varies depending on the endpoint and request.
  final dynamic data;

  /// The HTTP status code.
  ///
  /// WordPress REST API uses standard HTTP status codes to indicate the success
  /// or failure of an API request. Common codes include:
  /// - 200: OK - The request was successful
  /// - 201: Created - A new resource was successfully created
  /// - 400: Bad Request - The request was invalid or cannot be served
  /// - 401: Unauthorized - Authentication is required and has failed or not been provided
  /// - 403: Forbidden - The server understood the request but refuses to authorize it
  /// - 404: Not Found - The requested resource could not be found
  ///
  /// For a full list of status codes, see:
  /// https://developer.wordpress.org/rest-api/using-the-rest-api/status-codes/
  final int code;

  /// The HTTP response headers.
  ///
  /// WordPress REST API includes several custom headers in its responses:
  /// - X-WP-Total: The total number of items for the queried resource
  /// - X-WP-TotalPages: The total number of pages of data available
  /// - Link: Provides links to the next, previous, first, and last pages of data (for paginated responses)
  ///
  /// For more information on headers, see:
  /// https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/#_envelope
  final Map<String, dynamic> headers;

  /// The HTTP request headers.
  ///
  /// These are the headers that were sent with the original request to the API.
  final Map<String, dynamic> requestHeaders;

  /// Additional metadata associated with the response.
  ///
  /// This can include custom data passed along with the response.
  final Map<String, dynamic> extra;

  /// The request duration.
  ///
  /// This represents the time taken for the API request to complete.
  final Duration duration;

  /// An optional message describing the response.
  ///
  /// This can be used to provide additional context about the response,
  /// especially useful for error messages.
  final String? message;

  /// Returns the [RequestErrorType] for this response.
  ///
  /// This method interprets the HTTP status code to determine the type of error,
  /// if any, that occurred during the API request.
  RequestErrorType get errorType {
    if (isSuccessful) {
      return RequestErrorType.noError;
    }

    if (RequestErrorType.values.any((element) => -element.index == code)) {
      return RequestErrorType.values[-code];
    }

    return RequestErrorType.unknown;
  }

  /// Returns true if the given [code] is in the 200 to 399 range.
  ///
  /// This is used to determine if the API request was successful.
  /// Status codes in this range indicate various levels of success.
  bool get isSuccessful => isInRange(code, 200, 399);

  /// Returns true if the given [code] is not in the 200 to 399 range.
  ///
  /// This is a convenience method for `!isSuccessful`.
  /// It indicates that the API request encountered an error.
  bool get isFailure => !isSuccessful;

  /// Indicates whether this response is from a middleware.
  ///
  /// Some WordPress setups may include middleware that intercepts and modifies
  /// API responses. This property helps identify such cases.
  bool get isMiddlewareResponse => headers.containsKey(MIDDLEWARE_HEADER_KEY);

  /// Allows accessing response data using array notation.
  ///
  /// This operator provides a convenient way to access specific fields
  /// in the response data, assuming it's a map.
  ///
  /// Throws exceptions if the data is null or not a map.
  dynamic operator [](dynamic key) {
    if (data == null) {
      throw NullReferenceException('Response is null.');
    }

    if (data is! Map<String, dynamic>) {
      throw UnsupportedError('Response is not a map.');
    }

    return data[key];
  }

  /// Maps this raw response to a [WordpressResponse] instance.
  ///
  /// This method is used to convert the raw API response into a more
  /// structured format, either [WordpressSuccessResponse] or [WordpressFailureResponse].
  ///
  /// The [decoder] function is used to parse the response data into the desired type.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await client.posts.listRaw(PostsListRequest());
  /// final posts = response.asResponse<List<Post>>(
  ///   decoder: (data) => (data as Iterable<dynamic>).map((e) => Post.fromMap(e)).toList(),
  /// );
  /// ```
  WordpressResponse<T> asResponse<T>({
    required T Function(dynamic data) decoder,
  }) {
    if (isFailure) {
      return WordpressFailureResponse(
        error: WordpressError.fromMap(data),
        code: code,
        headers: headers,
        rawData: data,
        duration: duration,
        message: message,
        extra: extra,
        requestHeaders: requestHeaders,
      );
    }

    return WordpressSuccessResponse<T>(
      data: decoder(data),
      code: code,
      rawData: data,
      headers: headers,
      requestHeaders: requestHeaders,
      extra: extra,
      duration: duration,
      message: message,
    );
  }

  /// Retrieves a specific field from the response data.
  ///
  /// This method provides a safe way to access fields in the response data,
  /// with options for transformation and default values.
  ///
  /// [key]: The key of the field to retrieve.
  /// [throwIfError]: If true, throws an exception for failure responses.
  /// [transformer]: A function to transform the retrieved value.
  /// [orElse]: A function to provide a default value if the field is not found.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await client.posts.listRaw(PostsListRequest());
  /// final posts = response.getField<List<Post>>(
  ///   'data',
  ///   transformer: (data) => (data as Iterable<dynamic>).map((e) => Post.fromMap(e)).toList(),
  /// );
  /// ```
  T? getField<T, R>(
    R key, {
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

    if (data is! Map<String, dynamic>) {
      if (throwIfError) {
        throw UnsupportedError('Response is not a map.');
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

  /// Returns the error and stack trace if the response is a failure.
  ///
  /// This method is useful for debugging and error handling, providing
  /// access to detailed error information when an API request fails.
  (Object, StackTrace) getError() => (extra['error'], extra['stackTrace']);

  /// Maps this raw response to a [WordpressResponse] instance.
  ///
  /// This method allows for custom handling of success and failure responses.
  ///
  /// [onSuccess]: A function to handle successful responses.
  /// [onFailure]: A function to handle failure responses.
  ///
  /// This method is particularly useful when you need different logic
  /// for handling successful and failed API responses.
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

  /// Creates a copy of this [WordpressRawResponse] with the given fields replaced with new values.
  WordpressRawResponse copyWith({
    dynamic data,
    int? code,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? requestHeaders,
    Duration? duration,
    Map<String, dynamic>? extra,
    String? message,
  }) {
    return WordpressRawResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      headers: headers ?? this.headers,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      duration: duration ?? this.duration,
      extra: extra ?? this.extra,
      message: message ?? this.message,
    );
  }
}
