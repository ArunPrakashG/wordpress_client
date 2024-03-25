import 'dart:async';

import 'package:collection/collection.dart';

import '../library_exports.dart';
import 'parallel_raw_result.dart';

/// `ParallelWordpress` is a class that uses a `WordpressClient` to fetch data from a WordPress site.
/// It provides a method to fetch a list of items in parallel, which can significantly speed up the fetching process.
final class ParallelWordpress {
  /// Constructs a `ParallelWordpress` instance.
  ///
  /// Takes a `WordpressClient` object as a required parameter, which is used to make requests to the WordPress site.
  const ParallelWordpress({
    required this.client,
  });

  final WordpressClient client;

  /// Fetches a list of items of type `T` in parallel.
  ///
  /// The `requestBuilder` parameter is a function that builds a list of requests to be made.
  /// The `interface` parameter is a function that performs the list operation for each request.
  /// The `transformer` parameter is an optional function that transforms the results of each request.
  /// The `onException` parameter is an optional function that handles exceptions that occur during the processing of the requests.
  /// The `initial` parameter is an optional function that provides an initial list of items.
  ///
  /// Returns a `Future` that completes with a list of items of type `T`.
  Future<Iterable<ParallelResult<T>>> list<T, R extends IRequest>({
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
      eagerError: true,
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

    final sortedResults =
        results.sorted((a, b) => a.page.compareTo(b.page)).map((e) => e);

    if (initial == null) {
      return sortedResults;
    }

    final initialItems = ParallelResult(page: 0, results: await initial());

    return [initialItems, ...sortedResults];
  }
}
