class MapDoesNotExistException implements Exception {
  MapDoesNotExistException(this.message);

  final String message;

  @override
  String toString() => message;
}
