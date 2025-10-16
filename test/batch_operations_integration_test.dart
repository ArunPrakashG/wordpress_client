import 'package:test/test.dart';
import 'package:wordpress_client/src/batch/batch_interface.dart';
import 'package:wordpress_client/src/batch/batch_operations.dart';
import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/requests/wordpress_request.dart';
import 'package:wordpress_client/src/responses/wordpress_response.dart';
import 'package:wordpress_client/src/utilities/request_url.dart';

/// Mock executor that simulates WordPress REST API responses
class MockWordpressExecutor {
  MockWordpressExecutor({this.defaultDelay = const Duration(milliseconds: 10)});
  int callCount = 0;
  final Map<String, dynamic> responses = {};
  final Set<String> failingEndpoints = {};
  final Duration defaultDelay;

  /// Register a mock response for an endpoint
  void registerResponse(String endpoint, dynamic data) {
    responses[endpoint] = data;
  }

  /// Register an endpoint to fail
  void registerFailure(String endpoint) {
    failingEndpoints.add(endpoint);
  }

  /// Execute a request and return a mock response
  Future<WordpressResponse> execute(WordpressRequest request) async {
    callCount++;
    final endpoint = request.url.toString();

    // Simulate network delay
    await Future.delayed(defaultDelay);

    // Check if this endpoint should fail
    if (failingEndpoints.contains(endpoint)) {
      return WordpressFailureResponse(
        error: null,
        code: 404,
        rawData: const {'message': 'Not Found'},
        duration: defaultDelay,
      );
    }

    // Return registered response or default
    final data = responses[endpoint] ?? {'id': callCount, 'url': endpoint};

    return WordpressSuccessResponse(
      data: data,
      rawData: data,
      headers: const {'content-type': 'application/json'},
      requestHeaders: const {},
      duration: defaultDelay,
    );
  }
}

void main() {
  group('Batch Operations Integration Tests', () {
    late MockWordpressExecutor executor;
    late WordpressRequest postRequest;
    late WordpressRequest pageRequest;
    late WordpressRequest userRequest;

    setUp(() {
      executor = MockWordpressExecutor();

      postRequest = WordpressRequest(
        url: RequestUrl.relative('/posts'),
        method: HttpMethod.get,
      );

      pageRequest = WordpressRequest(
        url: RequestUrl.relative('/pages'),
        method: HttpMethod.get,
      );

      userRequest = WordpressRequest(
        url: RequestUrl.relative('/users'),
        method: HttpMethod.get,
      );

      // Register mock responses
      executor.registerResponse('/posts', {'id': 1, 'title': 'Post 1'});
      executor.registerResponse('/pages', {'id': 1, 'title': 'Page 1'});
      executor.registerResponse('/users', {'id': 1, 'name': 'User 1'});
    });

    group('Basic Batch Execution', () {
      test('executes single operation', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
        );

        batch.add(postRequest, operationId: 'posts');

        final response = await batch.execute();

        expect(response.operations.length, equals(1));
        expect(response.successCount, equals(1));
        expect(response.failureCount, equals(0));
        expect(response.allSuccess, isTrue);
        expect(executor.callCount, equals(1));
      });

      test('executes multiple operations sequentially', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 1),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        expect(response.operations.length, equals(3));
        expect(response.successCount, equals(3));
        expect(response.failureCount, equals(0));
        expect(response.allSuccess, isTrue);
        expect(executor.callCount, equals(3));
      });

      test('executes multiple operations concurrently', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 3),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final startTime = DateTime.now();
        final response = await batch.execute();
        final duration = DateTime.now().difference(startTime);

        expect(response.operations.length, equals(3));
        expect(response.successCount, equals(3));
        expect(response.failureCount, equals(0));
        expect(response.allSuccess, isTrue);
        expect(executor.callCount, equals(3));

        // Concurrent execution should be faster than sequential
        // (at least not 3x slower)
        expect(
          duration.inMilliseconds,
          lessThan(
            100, // Should complete in under 100ms for 3 operations
          ),
        );
      });
    });

    group('Error Handling', () {
      test('detects individual operation failures', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(continueOnError: true),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        expect(response.operations.length, equals(3));
        expect(response.successCount, equals(2));
        expect(response.failureCount, equals(1));
        expect(response.allSuccess, isFalse);
        expect(response.hasErrors, isTrue);
      });

      test('continues on error when configured', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            continueOnError: true,
            maxConcurrent: 1,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        // Should execute all operations despite one failing
        expect(executor.callCount, equals(3));
        expect(response.operations.length, equals(3));
      });

      test('fails fast in atomic mode', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            atomic: true,
            rollbackStrategy: RollbackStrategy.rollbackAll,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        expect(
          batch.execute,
          throwsA(isA<BatchOperationException>()),
        );
      });

      test('provides detailed error information', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(continueOnError: true),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages');

        final response = await batch.execute();

        final failures = response.failures;
        expect(failures, isNotEmpty);

        final failedOp = response.operations.firstWhere(
            (op) => op.id == 'pages',
            orElse: () => throw Exception());
        expect(failedOp.isFailed, isTrue);
        expect(failedOp.error, isNotNull);
        expect(failedOp.state, equals(BatchOperationState.failed));
      });
    });

    group('Atomic Transactions', () {
      test('commits all operations on success', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            atomic: true,
            rollbackStrategy: RollbackStrategy.rollbackAll,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        expect(response.allSuccess, isTrue);
        expect(response.successCount, equals(3));
        expect(response.failureCount, equals(0));

        // All operations should be in completed state
        for (final op in response.operations) {
          expect(op.state, equals(BatchOperationState.completed));
          expect(op.isSuccess, isTrue);
        }
      });

      test('rolls back all operations on failure', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            atomic: true,
            rollbackStrategy: RollbackStrategy.rollbackAll,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        try {
          await batch.execute();
          fail('Should have thrown BatchOperationException');
        } on BatchOperationException catch (e) {
          expect(e.message, contains('rolled back'));
          expect(e.rolledBack, isTrue);
          expect(e.failedOperations, isNotEmpty);
        }
      });
    });

    group('Progress Monitoring', () {
      test('emits progress updates', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 1),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final progressEvents = <(int, int)>[];
        batch.progressStream.listen(progressEvents.add);

        await batch.execute();

        // Should emit progress for each completed operation
        expect(progressEvents, isNotEmpty);
        expect(progressEvents.last.$2, equals(3)); // Total 3 operations
      });

      test('tracks operation timing', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
        );

        batch.add(postRequest, operationId: 'posts');

        final response = await batch.execute();

        final op = response.operations.first;
        expect(op.duration, isNotNull);
        expect(op.duration!.inMilliseconds, greaterThan(0));
        expect(op.startTime, isNotNull);
        expect(op.endTime, isNotNull);
        expect(op.endTime!.isAfter(op.startTime!), isTrue);
      });

      test('reports total batch duration', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 1),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages');

        final response = await batch.execute();

        expect(response.totalDuration, isNotNull);
        expect(response.totalDuration.inMilliseconds, greaterThan(0));
        expect(response.startTime, isNotNull);
        expect(response.endTime, isNotNull);
      });
    });

    group('Large Batch Operations', () {
      test('executes 100 operations successfully', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 10),
        );

        // Add 100 operations
        for (var i = 0; i < 100; i++) {
          batch.add(
            WordpressRequest(
              url: RequestUrl.relative('/posts/$i'),
              method: HttpMethod.get,
            ),
            operationId: 'op_$i',
          );
        }

        final response = await batch.execute();

        expect(response.operations.length, equals(100));
        expect(response.successCount, equals(100));
        expect(response.allSuccess, isTrue);
        expect(executor.callCount, equals(100));
      });

      test('handles 100 operations with 10 failures', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            continueOnError: true,
            maxConcurrent: 10,
          ),
        );

        // Add 100 operations
        for (var i = 0; i < 100; i++) {
          final endpoint = '/posts/$i';
          final request = WordpressRequest(
            url: RequestUrl.relative(endpoint),
            method: HttpMethod.get,
          );

          // Every 10th operation fails
          if (i % 10 == 0) {
            executor.registerFailure(endpoint);
          }

          batch.add(request, operationId: 'op_$i');
        }

        final response = await batch.execute();

        expect(response.operations.length, equals(100));
        expect(response.successCount, equals(90));
        expect(response.failureCount, equals(10));
        expect(response.allSuccess, isFalse);
      });
    });

    group('Cancellation', () {
      test('cancels pending operations', () async {
        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(maxConcurrent: 1),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        // Start execution in background
        final executeFuture = batch.execute();

        // Cancel after a short delay
        await Future.delayed(const Duration(milliseconds: 25));
        await batch.cancel();

        final response = await executeFuture;

        // Should have at least some cancelled operations
        final cancelledOps = response.operations
            .where((op) => op.state == BatchOperationState.cancelled)
            .toList();
        expect(cancelledOps, isNotEmpty);
      });
    });

    group('Configuration Validation', () {
      test('requires executor to be set', () async {
        final batch = BatchRequestImpl();

        batch.add(postRequest, operationId: 'posts');

        expect(
          batch.execute,
          throwsStateError,
        );
      });

      test('respects operation timeout configuration', () async {
        // Create executor with long delay
        final slowExecutor = MockWordpressExecutor(
          defaultDelay: const Duration(seconds: 5),
        );

        final batch = BatchRequestImpl(
          executor: slowExecutor.execute,
          config: const BatchConfig(
            operationTimeout: Duration(milliseconds: 100),
          ),
        );

        batch.add(postRequest, operationId: 'posts');

        expect(
          batch.execute,
          throwsException,
        );
      });

      test('respects concurrency limit', () async {
        var maxConcurrent = 0;
        var currentConcurrent = 0;

        Future<WordpressResponse> limitedExecutor(
          WordpressRequest request,
        ) async {
          currentConcurrent++;
          maxConcurrent = maxConcurrent > currentConcurrent
              ? maxConcurrent
              : currentConcurrent;

          await Future.delayed(const Duration(milliseconds: 50));

          currentConcurrent--;

          return const WordpressSuccessResponse(
            data: {'id': 1},
            rawData: {},
            headers: {},
            requestHeaders: {},
            duration: Duration.zero,
          );
        }

        final batch = BatchRequestImpl(
          executor: limitedExecutor,
          config: const BatchConfig(maxConcurrent: 3),
        );

        for (var i = 0; i < 10; i++) {
          batch.add(
            WordpressRequest(
              url: RequestUrl.relative('/item/$i'),
              method: HttpMethod.get,
            ),
            operationId: 'op_$i',
          );
        }

        final response = await batch.execute();

        expect(response.allSuccess, isTrue);
        // Max concurrent should not exceed configured limit
        expect(maxConcurrent, lessThanOrEqualTo(3));
      });
    });

    group('Response Aggregation', () {
      test('aggregates success and failure responses', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            continueOnError: true,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        expect(response.successes.length, equals(2));
        expect(response.failures.length, equals(1));

        // Verify we can access responses by operation
        for (final op in response.operations) {
          if (op.isSuccess) {
            expect(op.response, isA<WordpressSuccessResponse>());
          } else if (op.isFailed) {
            expect(op.error, isNotNull);
          }
        }
      });

      test('provides response statistics', () async {
        executor.registerFailure('/pages');

        final batch = BatchRequestImpl(
          executor: executor.execute,
          config: const BatchConfig(
            continueOnError: true,
          ),
        );

        batch
            .add(postRequest, operationId: 'posts')
            .add(pageRequest, operationId: 'pages')
            .add(userRequest, operationId: 'users');

        final response = await batch.execute();

        expect(response.successCount, equals(2));
        expect(response.failureCount, equals(1));
        expect(
          response.successCount + response.failureCount,
          equals(response.operations.length),
        );
      });
    });
  });
}
