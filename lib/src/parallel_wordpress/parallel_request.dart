import 'package:meta/meta.dart';

@immutable
final class ParallelRequest<T> {
  const ParallelRequest({
    required this.page,
    required this.request,
  });

  final int page;
  final T request;

  @override
  bool operator ==(covariant ParallelRequest<T> other) {
    if (identical(this, other)) return true;

    return other.page == page && other.request == request;
  }

  @override
  int get hashCode => page.hashCode ^ request.hashCode;
}
