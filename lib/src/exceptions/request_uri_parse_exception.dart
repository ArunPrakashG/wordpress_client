class RequestUriParsingFailedException implements Exception {
  final String reason;

  RequestUriParsingFailedException(this.reason);
}
