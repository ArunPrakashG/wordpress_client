import 'package:dio/dio.dart';

import '../responses/error_container.dart';

class Callback {
  const Callback({
    this.unhandledExceptionCallback,
    this.responseCallback,
    this.onReceiveProgress,
    this.requestErrorCallback,
    this.onSendProgress,
  });

  final void Function(Exception)? unhandledExceptionCallback;
  final void Function(ErrorContainer)? requestErrorCallback;
  final void Function(dynamic)? responseCallback;
  final void Function(int received, int total)? onReceiveProgress;
  final void Function(int send, int total)? onSendProgress;

  void invokeUnhandledExceptionCallback(Exception e) {
    if (unhandledExceptionCallback == null) {
      return;
    }

    unhandledExceptionCallback!(e);
  }

  void invokeDioErrorCallback(DioError error) {
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
        errorResponse: error.response!.data,
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

  void invokeReceiveProgressCallback(int current, int total) {
    if (onReceiveProgress == null) {
      return;
    }

    onReceiveProgress!(current, total);
  }

  void invokeSendProgressCallback(int current, int total) {
    if (onSendProgress == null) {
      return;
    }

    onSendProgress!(current, total);
  }
}
