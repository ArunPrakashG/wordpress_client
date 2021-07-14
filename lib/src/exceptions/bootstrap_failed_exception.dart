class BootstrapFailedException implements Exception {
  final String reason;
  BootstrapFailedException(this.reason);
}
