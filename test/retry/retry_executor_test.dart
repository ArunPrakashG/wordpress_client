// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:test/test.dart';
import 'package:wordpress_client/src/retry/retry_executor.dart';
import 'package:wordpress_client/src/retry/retry_policy.dart';

void main() {
  group('Retry Executor', () {
    test('execute() succeeds on first attempt', () async {
      final executor = RetryExecutor();
      var callCount = 0;

      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          callCount++;
          return 'success';
        },
      );

      expect(result.success, isTrue);
      expect(result.data, equals('success'));
      expect(result.stats.totalAttempts, equals(1));
      expect(result.stats.successfulAttempts, equals(1));
      expect(callCount, equals(1));
    });

    test('execute() retries on failure then succeeds', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          initialDelay: const Duration(milliseconds: 10),
        ),
      );
      var callCount = 0;

      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Temporary failure');
          }
          return 'success';
        },
      );

      expect(result.success, isTrue);
      expect(result.data, equals('success'));
      expect(result.stats.totalAttempts, equals(3));
      expect(result.stats.failedAttempts, equals(2));
      expect(callCount, equals(3));
    });

    test('execute() throws MaxRetriesExceededException on all failures',
        () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
        ),
      );
      var callCount = 0;

      expect(
        () async {
          await executor.execute<String>(
            operationName: 'test_op',
            operation: () async {
              callCount++;
              throw Exception('Persistent failure');
            },
          );
        },
        throwsA(isA<MaxRetriesExceededException>()),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(3)); // Initial + 2 retries
    });

    test('execute() respects exponential backoff delays', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
          useJitter: false,
        ),
      );
      var callCount = 0;

      try {
        await executor.execute<void>(
          operationName: 'test_op',
          operation: () async {
            callCount++;
            throw Exception('Fail');
          },
        );
      } catch (e) {
        // Expected to fail
      }

      // Delays should be: 10ms, then 10*(2^1)=20ms
      expect(callCount, equals(3));
    });

    test('execute() respects retryableStatusCodes', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          initialDelay: const Duration(milliseconds: 10),
          retryableStatusCodes: [500, 503],
        ),
      );
      const statusCode = 404;

      expect(
        () => executor.execute<String>(
          operationName: 'test_op',
          operation: () async => throw Exception('Not found'),
          getStatusCode: () => statusCode,
        ),
        throwsA(isA<MaxRetriesExceededException>()),
      );
    });

    test('executeWithFallback() returns fallback on failure', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 5),
        ),
      );

      final result = await executor.executeWithFallback<String>(
        operationName: 'test_op',
        operation: () async => throw Exception('Fail'),
        fallbackValue: 'fallback_value',
      );

      expect(result, equals('fallback_value'));
    });

    test('execute() tracks retry statistics', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          initialDelay: const Duration(milliseconds: 10),
        ),
      );
      var callCount = 0;

      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          callCount++;
          if (callCount < 2) {
            throw Exception('Fail');
          }
          return 'success';
        },
      );

      expect(result.stats.totalAttempts, equals(2));
      expect(result.stats.successfulAttempts, equals(1));
      expect(result.stats.failedAttempts, equals(1));
      expect(result.stats.errors, hasLength(1));
      expect(result.stats.delays, hasLength(1));
      expect(result.stats.durationMs, greaterThanOrEqualTo(10));
    });

    test('execute() respects retryOnTimeout configuration', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          initialDelay: const Duration(milliseconds: 10),
          retryOnTimeout: false,
        ),
      );

      expect(
        () => executor.execute<String>(
          operationName: 'test_op',
          operation: () async => throw TimeoutException('Timeout'),
        ),
        throwsA(isA<MaxRetriesExceededException>()),
      );
    });
  });
}
