class ClientNotInitializedException implements Exception {
  const ClientNotInitializedException(this.reason);

  final String reason;
}
