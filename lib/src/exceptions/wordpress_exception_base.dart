import '../enums.dart';

abstract class IWordpressException implements Exception {
  const IWordpressException(this.errorType, [this.message]) : super();

  final String? message;
  final ErrorType errorType;

  @override
  String toString() =>
      '[${DateTime.now().toString()}] ${errorType}Exception: $message';
}
