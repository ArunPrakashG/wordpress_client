import 'package:dio/dio.dart';

class ErrorContainer {
  ErrorContainer({this.errorResponse, this.internalError});

  final dynamic errorResponse;
  final DioError? internalError;
}
