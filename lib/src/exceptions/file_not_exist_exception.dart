class FileDoesntExistException implements Exception {
  final String reason;

  FileDoesntExistException(this.reason);
}
