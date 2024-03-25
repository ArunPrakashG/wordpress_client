import 'package:meta/meta.dart';

@immutable
final class ParallelResult<T> {
  const ParallelResult({
    required this.page,
    required this.results,
  });

  /// The page number of the results.
  ///
  /// Note that, if this instance contains results from the `initial()` method, then the `page` will be `0`.
  final int page;

  /// The results of the request.
  final Iterable<T> results;

  @override
  bool operator ==(covariant ParallelResult<T> other) {
    if (identical(this, other)) return true;

    return other.page == page && other.results == results;
  }

  @override
  int get hashCode => page.hashCode ^ results.hashCode;

  T operator [](int index) => results.elementAt(index);
}
