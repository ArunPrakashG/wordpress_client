class BootstrapFailedException implements Exception {
  const BootstrapFailedException(this.reason);

  final String reason;
}
