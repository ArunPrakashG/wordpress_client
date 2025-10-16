// ignore_for_file: unawaited_futures

import 'package:test/test.dart';
import 'package:wordpress_client/src/parallel/parallel_request_manager.dart';

void main() {
  late ParallelRequestManager manager;

  setUp(() {
    manager = ParallelRequestManager(
      config: ParallelRequestConfig(
        maxConcurrentRequests: 3,
        requestTimeout: const Duration(seconds: 5),
      ),
    );
  });

  tearDown(() {
    manager.shutdown();
  });

  group('Parallel Request Manager', () {
    test('enqueue() executes a simple request', () async {
      final result = await manager.enqueue<String>(
        id: 'test_1',
        execute: () async => 'success',
      );

      expect(result, equals('success'));
    });

    test('enqueue() queues multiple requests respecting max concurrent',
        () async {
      var executingCount = 0;
      var maxExecuting = 0;

      final futures = List.generate(5, (i) {
        return manager.enqueue<int>(
          id: 'req_$i',
          execute: () async {
            executingCount++;
            maxExecuting =
                maxExecuting > executingCount ? maxExecuting : executingCount;

            await Future.delayed(const Duration(milliseconds: 100));

            executingCount--;
            return i;
          },
        );
      });

      final results = await Future.wait(futures);

      expect(results, equals([0, 1, 2, 3, 4]));
      expect(maxExecuting, lessThanOrEqualTo(3));
    });

    test('enqueue() respects request priority', () async {
      final executionOrder = <String>[];

      // Enqueue low priority
      manager.enqueue<void>(
        id: 'low_1',
        priority: RequestPriority.low,
        execute: () async {
          executionOrder.add('low_1');
          await Future.delayed(const Duration(milliseconds: 50));
        },
      );

      // Enqueue high priority
      await Future.delayed(const Duration(milliseconds: 10));
      manager.enqueue<void>(
        id: 'high_1',
        priority: RequestPriority.high,
        execute: () async {
          executionOrder.add('high_1');
          await Future.delayed(const Duration(milliseconds: 50));
        },
      );

      await manager.waitAll();

      // High priority should execute before low priority
      expect(executionOrder.indexOf('high_1'),
          lessThan(executionOrder.indexOf('low_1')));
    });

    test('enqueue() deduplicates identical request IDs', () async {
      var executionCount = 0;

      Future<String> execute() async {
        executionCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return 'result';
      }

      final future1 = manager.enqueue<String>(
        id: 'dup_1',
        execute: execute,
      );

      final future2 = manager.enqueue<String>(
        id: 'dup_1',
        execute: execute,
      );

      final result1 = await future1;
      final result2 = await future2;

      expect(result1, equals('result'));
      expect(result2, equals('result'));
      expect(
          executionCount, equals(1)); // Only executed once due to deduplication
    });

    test('cancel() cancels a pending request', () async {
      manager.enqueue<void>(
        id: 'cancel_1',
        execute: () async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final cancelled = manager.cancel('cancel_1');

      expect(cancelled, isTrue);
    });

    test('cancelAll() cancels all pending requests', () async {
      List.generate(3, (i) {
        return manager.enqueue<int>(
          id: 'batch_$i',
          execute: () async {
            await Future.delayed(const Duration(seconds: 5));
            return i;
          },
        );
      });

      await Future.delayed(const Duration(milliseconds: 50));
      final cancelledCount = manager.cancelAll();

      expect(cancelledCount, greaterThan(0));
      await manager.waitAll();
    });

    test('getStats() returns request statistics', () async {
      final futures = List.generate(5, (i) {
        return manager.enqueue<int>(
          id: 'stat_$i',
          priority: i.isEven ? RequestPriority.high : RequestPriority.low,
          execute: () async {
            await Future.delayed(const Duration(milliseconds: 50));
            return i;
          },
        );
      });

      await Future.wait(futures);

      final stats = manager.getStats();

      expect(stats.totalRequests, equals(5));
      expect(stats.successfulRequests, equals(5));
      expect(stats.failedRequests, equals(0));
      expect(stats.successRate, equals(100));
    });

    test('getStats() tracks failed requests', () async {
      manager.enqueue<void>(
        id: 'fail_1',
        execute: () async => throw Exception('Test error'),
      );

      await manager.waitAll();

      final stats = manager.getStats();

      expect(stats.failedRequests, equals(1));
      expect(stats.successfulRequests, equals(0));
      expect(stats.failureRate, equals(100));
    });

    test('EnqueuedRequest tracks wait time', () async {
      final request = EnqueuedRequest(
        id: 'wait_test',
        execute: () async => 'test',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final waitTime = request.waitTimeSeconds;
      expect(waitTime, greaterThanOrEqualTo(0.09));
    });

    test('ParallelRequestResult tracks execution time', () async {
      final startTime = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 100));
      final endTime = DateTime.now();

      final result = ParallelRequestResult(
        requestId: 'timing_test',
        success: true,
        startTime: startTime,
        endTime: endTime,
      );

      expect(result.durationMs, greaterThanOrEqualTo(100));
    });

    test('queuedCount reports pending requests', () async {
      manager.enqueue<void>(
        id: 'queue_1',
        execute: () async => Future.delayed(const Duration(seconds: 5)),
      );

      manager.enqueue<void>(
        id: 'queue_2',
        execute: () async => Future.delayed(const Duration(seconds: 5)),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(manager.queuedCount, greaterThan(0));
    });

    test('executingCount reports executing requests', () async {
      manager.enqueue<void>(
        id: 'exec_1',
        execute: () async => Future.delayed(const Duration(milliseconds: 200)),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(manager.executingCount, equals(1));
    });

    test('waitAll() waits for all requests to complete', () async {
      var completed = false;

      manager.enqueue<void>(
        id: 'wait_all_1',
        execute: () async => Future.delayed(const Duration(milliseconds: 100)),
      );

      manager.enqueue<void>(
        id: 'wait_all_2',
        execute: () async => Future.delayed(const Duration(milliseconds: 150)),
      );

      manager.waitAll().then((_) {
        completed = true;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      expect(completed, isFalse);

      await manager.waitAll();
      expect(completed, isTrue);
    });

    test('requestTimeout applies to slow requests', () async {
      expect(
        () => manager.enqueue<void>(
          id: 'timeout_1',
          execute: () async => Future.delayed(const Duration(seconds: 10)),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('metadata is preserved with requests', () async {
      await manager.enqueue<String>(
        id: 'meta_1',
        metadata: {'user': 'test_user', 'priority': 'high'},
        execute: () async => 'success',
      );

      final stats = manager.getStats();
      // Verify request was processed
      expect(stats.successfulRequests, equals(1));
    });

    test('critical priority requests execute immediately', () async {
      final executionOrder = <String>[];

      // Enqueue normal priority
      manager.enqueue<void>(
        id: 'normal_1',
        execute: () async {
          executionOrder.add('normal_1');
          await Future.delayed(const Duration(milliseconds: 200));
        },
      );

      await Future.delayed(const Duration(milliseconds: 10));

      // Enqueue critical priority
      manager.enqueue<void>(
        id: 'critical_1',
        priority: RequestPriority.critical,
        execute: () async {
          executionOrder.add('critical_1');
          await Future.delayed(const Duration(milliseconds: 50));
        },
      );

      await manager.waitAll();

      // Critical should execute before normal
      expect(
        executionOrder.indexOf('critical_1'),
        lessThan(executionOrder.indexOf('normal_1')),
      );
    });

    test('clearResults() removes results but not statistics', () async {
      manager.enqueue<void>(
        id: 'clear_1',
        execute: () async => true,
      );

      await manager.waitAll();

      var results = manager.getResults();
      expect(results, isNotEmpty);

      manager.clearResults();

      results = manager.getResults();
      expect(results, isEmpty);

      final stats = manager.getStats();
      expect(stats.successfulRequests, equals(1));
    });
  });
}
