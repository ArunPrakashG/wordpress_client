class NullStatusCodeException implements Exception {
  NullStatusCodeException(this.message);

  final String message;

  @override
  String toString() => message;
}
