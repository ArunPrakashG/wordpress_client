class MapAlreadyExistException implements Exception {
  MapAlreadyExistException(this.message);

  final String message;

  @override
  String toString() => message;
}
