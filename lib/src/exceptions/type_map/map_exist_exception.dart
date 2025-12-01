class MapAlreadyExistException implements Exception {
  const MapAlreadyExistException(this.message);

  final String message;

  @override
  String toString() => message;
}
