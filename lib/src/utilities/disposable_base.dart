abstract interface class IDisposable {
  /// Indicates if this instance is already disposed.
  bool get disposed;

  /// Disposes any stored data of this instance, manually.
  void dispose();
}
