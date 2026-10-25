import 'package:meta/meta.dart';

import '../enums.dart';
import 'wordpress_error.dart';

/// Why a request failed, as a closed set of cases.
///
/// Every `WordpressFailureResponse` exposes one through its `failure` getter,
/// so callers can switch exhaustively instead of decoding status codes:
///
/// ```dart
/// final response = await client.posts.retrieve(RetrievePostRequest(id: 1));
///
/// if (response is WordpressFailureResponse) {
///   switch (response.failure) {
///     case NetworkFailure(:final kind):
///       showOffline(kind);
///     case AuthFailure():
///       promptLogin();
///     case ApiFailure(:final error):
///       showMessage(error?.message);
///     case DecodeFailure():
///     case MiddlewareFailure():
///     case ClientFailure():
///       report(response.failure);
///   }
/// }
/// ```
@immutable
sealed class WordpressFailure {
  const WordpressFailure({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// A human readable description.
  final String message;

  /// The exception that caused the failure, when there was one.
  final Object? cause;

  /// The stack trace captured with [cause].
  final StackTrace? stackTrace;

  @override
  String toString() => 'WordpressFailure($message)';
}

/// The kind of transport problem behind a [NetworkFailure].
enum NetworkFailureKind {
  /// Connecting, sending or receiving took longer than the configured timeout.
  timeout,

  /// The server could not be reached (DNS, refused, reset, TLS).
  connection,

  /// The request was cancelled through its `CancelToken`.
  cancelled,
}

/// The request never produced an HTTP response.
final class NetworkFailure extends WordpressFailure {
  const NetworkFailure({
    required this.kind,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  final NetworkFailureKind kind;
}

/// Why an [AuthFailure] happened.
enum AuthFailureReason {
  /// The request needs authorization but no authorization module is configured.
  noAuthorization,

  /// The configured credentials were rejected while authorizing.
  credentialsRejected,

  /// The server answered 401.
  unauthorized,

  /// The server answered 403.
  forbidden,
}

/// Authorization is missing, was rejected, or is not sufficient.
final class AuthFailure extends WordpressFailure {
  const AuthFailure({
    required this.reason,
    required super.message,
    this.statusCode,
    this.error,
    super.cause,
    super.stackTrace,
  });

  final AuthFailureReason reason;

  /// The HTTP status, when the server answered.
  final int? statusCode;

  /// The WordPress error payload, when the server sent one.
  final WordpressError? error;
}

/// The server answered with a non-success HTTP status.
final class ApiFailure extends WordpressFailure {
  const ApiFailure({
    required this.statusCode,
    required super.message,
    this.error,
    this.body,
    super.cause,
    super.stackTrace,
  });

  final int statusCode;

  /// The parsed WordPress error payload (`code`, `message`, `data.status`).
  final WordpressError? error;

  /// The raw response body, useful when the server did not send a WordPress error.
  final dynamic body;
}

/// The server answered successfully but the body could not be decoded.
final class DecodeFailure extends WordpressFailure {
  const DecodeFailure({
    required this.statusCode,
    required this.rawData,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  /// The (successful) HTTP status of the response that failed to decode.
  final int statusCode;

  final dynamic rawData;
}

/// A middleware aborted the request or threw while running.
final class MiddlewareFailure extends WordpressFailure {
  const MiddlewareFailure({
    required this.aborted,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  /// True when a middleware deliberately aborted the request.
  final bool aborted;
}

/// The request was rejected locally or hit an unexpected internal error.
final class ClientFailure extends WordpressFailure {
  const ClientFailure({
    required this.type,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  /// Which local condition occurred (for example [RequestErrorType.originMismatch]).
  final RequestErrorType type;
}

/// Classifies a failed response. Used by `WordpressFailureResponse.failure`.
@internal
WordpressFailure classifyFailure({
  required int code,
  required WordpressError? error,
  required String? message,
  required dynamic rawData,
  Map<String, dynamic>? extra,
}) {
  final cause = extra?['error'];
  final stackTrace = extra?['stackTrace'];
  final text = message ?? error?.message ?? 'Request failed.';
  final trace = stackTrace is StackTrace ? stackTrace : null;

  if (code >= 0) {
    if (code == 401 || code == 403) {
      return AuthFailure(
        reason: code == 401
            ? AuthFailureReason.unauthorized
            : AuthFailureReason.forbidden,
        statusCode: code,
        error: error,
        message: error?.message ?? text,
        cause: cause,
        stackTrace: trace,
      );
    }

    return ApiFailure(
      statusCode: code,
      error: error,
      body: rawData,
      message: error?.message ?? text,
      cause: cause,
      stackTrace: trace,
    );
  }

  final type = -code < RequestErrorType.values.length
      ? RequestErrorType.values[-code]
      : RequestErrorType.unknown;

  switch (type) {
    case RequestErrorType.timeout:
      return NetworkFailure(
        kind: NetworkFailureKind.timeout,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
    case RequestErrorType.connectionFailed:
      return NetworkFailure(
        kind: NetworkFailureKind.connection,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
    case RequestErrorType.requestCancelled:
      return NetworkFailure(
        kind: NetworkFailureKind.cancelled,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
    case RequestErrorType.authorizationModuleNotFound:
      return AuthFailure(
        reason: AuthFailureReason.noAuthorization,
        message: text,
      );
    case RequestErrorType.authorizationFailedWithProvidedCredentials:
      return AuthFailure(
        reason: AuthFailureReason.credentialsRejected,
        message: text,
      );
    case RequestErrorType.invalidResponse:
      return DecodeFailure(
        statusCode:
            extra?['statusCode'] is int ? extra!['statusCode'] as int : 0,
        rawData: rawData,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
    case RequestErrorType.middlewareAborted:
    case RequestErrorType.middlewareExecutionFailed:
      return MiddlewareFailure(
        aborted: type == RequestErrorType.middlewareAborted,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
    case RequestErrorType.noError:
    case RequestErrorType.unknown:
    case RequestErrorType.internalGenericError:
    case RequestErrorType.invalidStatusCode:
    case RequestErrorType.originMismatch:
      return ClientFailure(
        type: type,
        message: text,
        cause: cause,
        stackTrace: trace,
      );
  }
}
