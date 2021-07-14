class ClientNotInitializedException implements Exception {
  final String reason;

  ClientNotInitializedException(this.reason);
}
