import 'package:dio/dio.dart';

import '../responses/error_container.dart';

typedef ReceiveProgressCallback = void Function(int received, int total);
typedef SendProgressCallback = void Function(int sent, int total);

class WordpressCallback {
  const WordpressCallback({
    this.unhandledExceptionCallback,
    this.responseCallback,
    this.onReceiveProgress,
    this.requestErrorCallback,
    this.onSendProgress,
  });

  /// Invoked when an unhandled exception occurs.
  final void Function(dynamic unhandledException)? unhandledExceptionCallback;

  /// Invoked from an exception is thrown from internal [Dio] instance or from a failed request.
  final void Function(ErrorContainer errorContainer)? requestErrorCallback;

  /// Invoked when response is received.
  ///
  /// Argument [response] can be of any type, depending on the response received. Mostly, its a [Map] or [List] or [String].
  final void Function(dynamic response)? responseCallback;

  /// Invoked when response is received. This is directly invoked from [Dio].
  final ReceiveProgressCallback? onReceiveProgress;

  /// Invoked when request is sent. This is directly invoked from [Dio].
  final SendProgressCallback? onSendProgress;

  void invokeUnhandledExceptionCallback(dynamic e) {
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
