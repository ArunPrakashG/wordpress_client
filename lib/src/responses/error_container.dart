import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

@immutable
class ErrorContainer {
  const ErrorContainer({this.errorResponse, this.internalError});

  final dynamic errorResponse;
  final DioError? internalError;

  @override
  bool operator ==(covariant ErrorContainer other) {
    if (identical(this, other)) {
      return true;
    }

    return other.errorResponse == errorResponse &&
        other.internalError == internalError;
  }

  @override
  int get hashCode => errorResponse.hashCode ^ internalError.hashCode;

  @override
  String toString() =>
      'ErrorContainer(errorResponse: $errorResponse, internalError: $internalError)';
}
