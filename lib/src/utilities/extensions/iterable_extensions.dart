extension IterableExtensions<E> on Iterable<E> {
  Future<T> foldAsync<T>(
    T initialValue,
    Future<T> Function(T previousValue, E element) combine,
  ) async {
    var value = initialValue;

    for (final element in this) {
      value = await combine(value, element);
    }

    return value;
  }
}
