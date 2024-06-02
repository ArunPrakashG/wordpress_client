import '../enums.dart';

abstract class WordpressException implements Exception {
  const WordpressException(this.errorType, [this.message]) : super();

  final String? message;
  final ErrorType errorType;

  @override
  String toString() => '[${DateTime.now()}] $errorType $message';
}
