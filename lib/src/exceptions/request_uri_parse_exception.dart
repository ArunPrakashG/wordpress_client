class RequestUriParsingFailedException implements Exception {
  const RequestUriParsingFailedException(this.reason);

  final String reason;
}
