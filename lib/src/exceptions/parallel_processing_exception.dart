final class ParallelProcessingException implements Exception {
  const ParallelProcessingException(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'ParallelProcessingException: $error';
  }
}
