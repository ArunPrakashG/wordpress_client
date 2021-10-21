import 'package:dio/dio.dart';

import '../responses/error_container.dart';
import '../responses/error_response.dart';

class Callback {
  final void Function(Exception)? unhandledExceptionCallback;
  final void Function(ErrorContainer)? requestErrorCallback;
  final void Function(dynamic)? responseCallback;
  final void Function(int, int)? onReceiveProgress;
  final void Function(int, int)? onSendProgress;

  const Callback({
    this.unhandledExceptionCallback,
    this.responseCallback,
    this.onReceiveProgress,
    this.requestErrorCallback,
    this.onSendProgress,
  });

  void invokeUnhandledExceptionCallback(Exception e) {
    if (unhandledExceptionCallback == null) {
      return;
    }

    unhandledExceptionCallback!(e);
  }

  void invokeRequestErrorCallback(DioError error) {
    if (requestErrorCallback == null) {
      return;
    }

    if (error.response!.data == null) {
      return requestErrorCallback!(
        ErrorContainer(
          errorResponse: null,
          internalError: error,
        ),
      );
    }

    requestErrorCallback!(
      ErrorContainer(
        errorResponse:
            error.response!.data is Map<String, dynamic> ? ErrorResponse.fromMap(error.response!.data) : ErrorResponse.fromJson(error.response!.data),
        internalError: error,
      ),
    );
  }

  void invokeResponseCallback(dynamic response) {
    if (responseCallback == null) {
      return;
    }

    responseCallback!(response);
  }

  void invokeReceiveProgressCallback(int total, int current) {
    if (onReceiveProgress == null) {
      return;
    }

    onReceiveProgress!(total, current);
  }

  void invokeSendProgressCallback(int total, int current) {
    if (onSendProgress == null) {
      return;
    }

    onSendProgress!(total, current);
  }
}
