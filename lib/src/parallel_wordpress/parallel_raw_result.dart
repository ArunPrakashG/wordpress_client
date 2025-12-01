import 'package:meta/meta.dart';

@immutable
final class ParallelRawResult<T> {
  const ParallelRawResult({
    required this.page,
    required this.results,
  });

  final int page;
  final T results;
}
