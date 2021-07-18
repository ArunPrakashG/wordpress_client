import 'package:dio/dio.dart';

class Callback {
  final void Function(Exception) unhandledExceptionCallback;
  final void Function(DioError) requestErrorCallback;
  final void Function(dynamic) responseCallback;
  final void Function(int, int) onReceiveProgress;
  final void Function(int, int) onSendProgress;

  Callback({
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

    unhandledExceptionCallback(e);
  }

  void invokeRequestErrorCallback(DioError error) {
    if (requestErrorCallback == null) {
      return;
    }

    requestErrorCallback(error);
  }

  void invokeResponseCallback(dynamic response) {
    if (responseCallback == null) {
      return;
    }

    responseCallback(response);
  }

  void invokeReceiveProgressCallback(int total, int current) {
    if (onReceiveProgress == null) {
      return;
    }

    onReceiveProgress(total, current);
  }

  void invokeSendProgressCallback(int total, int current) {
    if (onSendProgress == null) {
      return;
    }

    onSendProgress(total, current);
  }
}
