abstract base class CacheExceptionBase implements Exception {
  const CacheExceptionBase({
    required this.message,
    this.cause,
  });

  final String message;
  final Exception? cause;
}
