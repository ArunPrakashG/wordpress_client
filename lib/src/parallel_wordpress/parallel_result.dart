import 'package:meta/meta.dart';

@immutable
final class ParallelResult<T> {
  const ParallelResult({
    required this.page,
    required this.results,
  });

  final int page;
  final Iterable<T> results;

  @override
  bool operator ==(covariant ParallelResult<T> other) {
    if (identical(this, other)) return true;

    return other.page == page && other.results == results;
  }

  @override
  int get hashCode => page.hashCode ^ results.hashCode;
}
