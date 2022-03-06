class FileDoesntExistException implements Exception {
  const FileDoesntExistException(this.reason);

  final String reason;
}
