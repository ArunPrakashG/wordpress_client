// ignore_for_file: comment_references

import 'package:dio/dio.dart';

import '../responses/wordpress_error.dart';

typedef ReceiveProgressCallback = void Function(int received, int total);
typedef SendProgressCallback = void Function(int sent, int total);

class WordpressEvents {
  const WordpressEvents({
    this.onError,
    this.onResponse,
    this.onReceive,
    this.onSend,
    this.onCancel,
  });

  /// Invoked from an exception is thrown from internal [Dio] instance or from a failed request.
  final void Function(WordpressError error)? onError;

  /// Invoked when response is received.
  ///
  /// Argument [response] can be of any type, depending on the response received. Mostly, its a [Map] or [List] or [String].
  final void Function(dynamic response)? onResponse;

  /// Invoked when response is received. This is directly invoked from [Dio].
  final ReceiveProgressCallback? onReceive;

  /// Invoked when request is sent. This is directly invoked from [Dio].
  final SendProgressCallback? onSend;

  final void Function()? onCancel;
}
