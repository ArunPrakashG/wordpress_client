import 'dart:async';

import 'package:collection/collection.dart';

import '../library_exports.dart';
import 'parallel_raw_result.dart';

/// `ParallelWordpress` is a class that uses a `WordpressClient` to perform parallel operations on a WordPress site.
/// It provides methods to fetch, create, update, delete, and retrieve items in parallel, which can significantly speed up the process.
final class ParallelWordpress {
  /// Constructs a `ParallelWordpress` instance.
  ///
  /// Takes a `WordpressClient` object as a required parameter, which is used to make requests to the WordPress site.
  const ParallelWordpress({
    required this.client,
  });

  /// The WordPress client used to make API requests.
  final WordpressClient client;

  /// Fetches a list of items of type `T` in parallel.
  ///
  /// Parameters:
  /// - `requestBuilder`: A function that builds a list of requests to be made.
  /// - `interface`: A function that performs the list operation for each request.
  /// - `transformer`: An optional function that transforms the results of each request.
  /// - `onException`: An optional function that handles exceptions that occur during the processing of the requests.
  /// - `initial`: An optional function that provides an initial list of items.
  ///
  /// Returns a `Future` that completes with an `Iterable` of `ParallelIterableResult<T>`.
  Future<Iterable<ParallelIterableResult<T>>> list<T, R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required ListOperation<T, R> interface,
    ParallelIterableResultTransformer<T>? transformer,
    ParallelIterableExceptionHandler<T>? onException,
    ParallelInitialItems<T>? initial,
    bool failOnError = false,
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
      (response) async => guardAsync(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          if (!response.results.isSuccessful) {
            if (failOnError) {
              // Force strict behavior: throw on first failure
              throw ParallelProcessingException(
                'Non-success response for page ${response.page}: ${response.results.code}',
                StackTrace.current,
              );
            }
            // Gracefully degrade: treat failed pages as empty results
            return ParallelIterableResult(
              page: response.page,
              results: <T>[], // ignore: prefer_const_literals_to_create_immutables
            );
          }
          final successResponse = response.results.asSuccess();

          return ParallelIterableResult(
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

    final initialItems =
        ParallelIterableResult(page: 0, results: await initial());

    return [initialItems, ...sortedResults];
  }

  /// Creates multiple items of type `T` in parallel.
  ///
  /// Parameters:
  /// - `requestBuilder`: A function that builds a list of requests to be made.
  /// - `interface`: A function that performs the create operation for each request.
  /// - `transformer`: An optional function that transforms the results of each request.
  /// - `onException`: An optional function that handles exceptions that occur during the processing of the requests.
  /// - `initial`: An optional function that provides an initial item.
  ///
  /// Returns a `Future` that completes with an `Iterable` of `ParallelResult<T>`.
  Future<Iterable<ParallelResult<T>>> create<T, R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required CreateOperation<T, R> interface,
    ParallelResultTransformer<T>? transformer,
    ParallelExceptionHandler<T>? onException,
    ParallelInitialItem<T>? initial,
  }) async {
    final requests = await requestBuilder();

    final responses = await Future.wait(
      requests.map((x) async {
        return ParallelRawResult(
          page: x.page,
          results: await interface.create(x.request),
        );
      }),
      eagerError: true,
    );

    final results = await responses.mapAsync(
      (response) async => guardAsync(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          final successResponse = response.results.asSuccess();

          return ParallelResult(
            page: response.page,
            result: successResponse.data,
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

    final initialItem = ParallelResult(page: 0, result: await initial());
    return [initialItem, ...sortedResults];
  }

  /// Updates multiple items of type `T` in parallel.
  ///
  /// Parameters:
  /// - `requestBuilder`: A function that builds a list of requests to be made.
  /// - `interface`: A function that performs the update operation for each request.
  /// - `transformer`: An optional function that transforms the results of each request.
  /// - `onException`: An optional function that handles exceptions that occur during the processing of the requests.
  /// - `initial`: An optional function that provides an initial item.
  ///
  /// Returns a `Future` that completes with an `Iterable` of `ParallelResult<T>`.
  Future<Iterable<ParallelResult<T>>> update<T, R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required UpdateOperation<T, R> interface,
    ParallelResultTransformer<T>? transformer,
    ParallelExceptionHandler<T>? onException,
    ParallelInitialItem<T>? initial,
  }) async {
    final requests = await requestBuilder();

    final responses = await Future.wait(
      requests.map((x) async {
        return ParallelRawResult(
          page: x.page,
          results: await interface.update(x.request),
        );
      }),
      eagerError: true,
    );

    final results = await responses.mapAsync(
      (response) async => guardAsync(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          final successResponse = response.results.asSuccess();

          return ParallelResult(
            page: response.page,
            result: successResponse.data,
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

    final initialItem = ParallelResult(page: 0, result: await initial());
    return [initialItem, ...sortedResults];
  }

  /// Deletes multiple items in parallel.
  ///
  /// Parameters:
  /// - `requestBuilder`: A function that builds a list of requests to be made.
  /// - `interface`: A function that performs the delete operation for each request.
  /// - `transformer`: An optional function that transforms the results of each request.
  /// - `onException`: An optional function that handles exceptions that occur during the processing of the requests.
  /// - `initial`: An optional function that provides an initial boolean value.
  ///
  /// Returns a `Future` that completes with an `Iterable` of `ParallelResult<bool>`.
  Future<Iterable<ParallelResult<bool>>> delete<R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required DeleteOperation<R> interface,
    ParallelResultTransformer<bool>? transformer,
    ParallelExceptionHandler<bool>? onException,
    ParallelInitialItem<bool>? initial,
  }) async {
    final requests = await requestBuilder();

    final responses = await Future.wait(
      requests.map((x) async {
        return ParallelRawResult(
          page: x.page,
          results: await interface.delete(x.request),
        );
      }),
      eagerError: true,
    );

    final results = await responses.mapAsync(
      (response) async => guardAsync(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          final successResponse = response.results.asSuccess();

          return ParallelResult(
            page: response.page,
            result: successResponse.data,
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

    final initialItem = ParallelResult(page: 0, result: await initial());
    return [initialItem, ...sortedResults];
  }

  /// Retrieves multiple items of type `T` in parallel.
  ///
  /// Parameters:
  /// - `requestBuilder`: A function that builds a list of requests to be made.
  /// - `interface`: A function that performs the retrieve operation for each request.
  /// - `transformer`: An optional function that transforms the results of each request.
  /// - `onException`: An optional function that handles exceptions that occur during the processing of the requests.
  /// - `initial`: An optional function that provides an initial item.
  ///
  /// Returns a `Future` that completes with an `Iterable` of `ParallelResult<T>`.
  Future<Iterable<ParallelResult<T>>> retrieve<T, R extends IRequest>({
    required RequestBuilder<R> requestBuilder,
    required RetrieveOperation<T, R> interface,
    ParallelResultTransformer<T>? transformer,
    ParallelExceptionHandler<T>? onException,
    ParallelInitialItem<T>? initial,
  }) async {
    final requests = await requestBuilder();

    final responses = await Future.wait(
      requests.map((x) async {
        return ParallelRawResult(
          page: x.page,
          results: await interface.retrieve(x.request),
        );
      }),
      eagerError: true,
    );

    final results = await responses.mapAsync(
      (response) async => guardAsync(
        function: () async {
          if (transformer != null) {
            return await transformer(response.results);
          }

          final successResponse = response.results.asSuccess();

          return ParallelResult(
            page: response.page,
            result: successResponse.data,
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

    final initialItem = ParallelResult(page: 0, result: await initial());
    return [initialItem, ...sortedResults];
  }
}
