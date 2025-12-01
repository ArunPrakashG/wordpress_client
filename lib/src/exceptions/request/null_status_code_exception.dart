class NullStatusCodeException implements Exception {
  const NullStatusCodeException(this.message);

  final String message;

  @override
  String toString() => message;
}
