class MiddlewareAbortedException implements Exception {
  const MiddlewareAbortedException({
    this.message = 'Middleware aborted the request',
  });

  final String message;

  @override
  String toString() => message;
}
