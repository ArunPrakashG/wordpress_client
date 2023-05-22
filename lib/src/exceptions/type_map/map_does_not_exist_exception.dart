class MapDoesNotExistException implements Exception {
  const MapDoesNotExistException(this.message);

  final String message;

  @override
  String toString() => message;
}
