// ignore_for_file: comment_references

import 'package:dio/dio.dart';

import '../responses/wordpress_error.dart';

/// Callback function type for receiving progress updates.
///
/// [received] is the number of bytes received so far.
/// [total] is the total number of bytes expected to be received.
typedef ReceiveProgressCallback = void Function(int received, int total);

/// Callback function type for sending progress updates.
///
/// [sent] is the number of bytes sent so far.
/// [total] is the total number of bytes to be sent.
typedef SendProgressCallback = void Function(int sent, int total);

/// A class to handle various events related to WordPress API requests.
class WordpressEvents {
  /// Creates a [WordpressEvents] instance with optional callback functions.
  const WordpressEvents({
    this.onError,
    this.onResponse,
    this.onReceive,
    this.onSend,
    this.onCancel,
  });

  /// Callback function invoked when an exception is thrown from the internal [Dio] instance or when a request fails.
  ///
  /// The [error] parameter contains details about the WordPress-specific error that occurred.
  final void Function(WordpressError error)? onError;

  /// Callback function invoked when a response is received from the WordPress API.
  ///
  /// The [response] parameter can be of any type, depending on the response received.
  /// It is typically a [Map], [List], or [String].
  final void Function(dynamic response)? onResponse;

  /// Callback function invoked when receiving data from the WordPress API.
  ///
  /// This callback is directly invoked from [Dio] and provides progress updates during data reception.
  final ReceiveProgressCallback? onReceive;

  /// Callback function invoked when sending data to the WordPress API.
  ///
  /// This callback is directly invoked from [Dio] and provides progress updates during data transmission.
  final SendProgressCallback? onSend;

  /// Callback function invoked when a request is cancelled.
  final void Function()? onCancel;
}
