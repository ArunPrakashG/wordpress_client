import 'package:dio/dio.dart';

class ErrorContainer {
  const ErrorContainer({this.errorResponse, this.internalError});

  final dynamic errorResponse;
  final DioError? internalError;
}
