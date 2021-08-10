import 'package:dio/dio.dart';
import 'package:wordpress_client/src/responses/error_response.dart';

class ErrorContainer {
  ErrorContainer({this.errorResponse, this.internalError});

  final ErrorResponse? errorResponse;
  final DioError? internalError;
}
