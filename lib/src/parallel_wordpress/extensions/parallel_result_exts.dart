import '../parallel_result.dart';

/// Extension methods for [Iterable<ParallelResult<T>>].
extension ParallelResultExts<T> on Iterable<ParallelResult<T>> {
  /// Converts this iterable of [ParallelResult<T>] into a [Stream].
  ///
  /// This method allows you to work with the results as a stream, which can be
  /// useful for processing results asynchronously or applying stream operations.
  ///
  /// Example:
  /// ```dart
  /// final results = [ParallelResult<int>(1), ParallelResult<int>(2), ParallelResult<int>(3)];
  /// final stream = results.streamed();
  /// await for (final result in stream) {
  ///   print(result.value);
  /// }
  /// ```
  Stream<ParallelResult<T>> streamed() {
    return Stream.fromIterable(this);
  }
}

/// Extension methods for [Iterable<ParallelIterableResult<T>>].
extension ParallelIterableResultExts<T> on Iterable<ParallelIterableResult<T>> {
  /// Converts this iterable of [ParallelIterableResult<T>] into a [Stream].
  ///
  /// This method is particularly useful when working with results that contain
  /// iterables, allowing you to process them as a stream.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   ParallelIterableResult<String>(['a', 'b']),
  ///   ParallelIterableResult<String>(['c', 'd']),
  /// ];
  /// final stream = results.streamed();
  /// await for (final result in stream) {
  ///   for (final item in result.value) {
  ///     print(item);
  ///   }
  /// }
  /// ```
  Stream<ParallelIterableResult<T>> streamed() {
    return Stream.fromIterable(this);
  }
}
