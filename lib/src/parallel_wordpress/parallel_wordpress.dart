import 'dart:async';

import 'package:collection/collection.dart';

import '../library_exports.dart';
import 'parallel_raw_result.dart';

final class ParallelWordpress {
  const ParallelWordpress({
    required this.client,
  });

  final WordpressClient client;

  Future<List<T>> list<T, R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required ListOperation<T, R> interface,
    ParallelResultTransformer<T>? transformer,
    ParallelExceptionHandler<T>? onException,
    ParallelInitialItems<T>? initial,
  }) async {
    final requests = await requestBuilder();

    final responses = await Future.wait(
      requests.map((x) async {
        return ParallelRawResult(
          page: x.page,
          results: await interface.list(x.request),
        );
      }),
    );

    final results = await responses.mapAsync(
      (response) async => executeGuarded(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          final successResponse = response.results.asSuccess();

          return ParallelResult(
            page: response.page,
            results: successResponse.data,
          );
        },
        onError: (error, stackTrace) async {
          if (onException != null) {
            return await onException(error);
          }

          throw ParallelProcessingException(error, stackTrace);
        },
      ),
    );

    final sortedResults = results
        .sorted((a, b) => a.page.compareTo(b.page))
        .map((e) => e.results);

    return sortedResults.fold<List<T>>(
      initial != null ? await initial() : <T>[],
      (previousValue, element) =>
          previousValue.followedBy(element).map((e) => e).toList(),
    );
  }
}
