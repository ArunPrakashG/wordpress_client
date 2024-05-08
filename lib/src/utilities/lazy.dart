/// A lazy value that is initialized by a supplier function the first time it is accessed.
final class Lazy<T> {
  Lazy(this._supplier);

  final T Function() _supplier;
  T? _value;

  /// Returns the value of this lazy instance. If the value has not been initialized, it will be initialized by calling the supplier function.
  T get value => _value ??= _supplier();

  /// Returns true if the value has been initialized.
  bool get initialized => _value != null;

  /// Resets the value of this lazy instance.
  ///
  /// The next time the value is accessed, it will be re-initialized by calling the supplier function.
  void reset() => _value = null;

  T call() => value;
}
