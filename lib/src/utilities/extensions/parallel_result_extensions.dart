import '../../library_exports.dart';

extension ParallelResultExtensions<T> on Iterable<ParallelResult<T>> {
  /// Merges the results of the parallel requests into a single list.
  Iterable<T> merge() {
    return fold<List<T>>(
      <T>[],
      (previousValue, element) =>
          previousValue.followedBy(element.results).map((e) => e).toList(),
    );
  }
}

extension FutureParallelResultExtensions<T>
    on Future<Iterable<ParallelResult<T>>> {
  /// Merges the results of the parallel requests into a single list.
  Future<Iterable<T>> merge() async {
    final results = await this;

    return results.fold<List<T>>(
      <T>[],
      (previousValue, element) =>
          previousValue.followedBy(element.results).map((e) => e).toList(),
    );
  }
}
