// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:test/test.dart';
import 'package:wordpress_client/src/retry/circuit_breaker.dart';
import 'package:wordpress_client/src/retry/retry_executor.dart';
import 'package:wordpress_client/src/retry/retry_policy.dart';

void main() {
  group('Retry + Circuit Breaker Integration', () {
    test('retry succeeds before circuit opens', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(),
      );
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
        ),
      );

      var attemptCount = 0;

      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          return breaker.execute<String>(
            operationName: 'wrapped_op',
            operation: () async {
              attemptCount++;
              if (attemptCount < 2) {
                throw Exception('Temporary failure');
              }
              return 'success';
            },
          );
        },
      );

      expect(result.success, isTrue);
      expect(result.data, equals('success'));
      expect(breaker.isClosed, isTrue);
    });

    test('circuit opens before retry exhaustion', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 2),
      );
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 5,
          initialDelay: const Duration(milliseconds: 10),
        ),
      );

      var operationAttempts = 0;

      try {
        await executor.execute<String>(
          operationName: 'test_op',
          operation: () async {
            return breaker.execute<String>(
              operationName: 'wrapped_op',
              operation: () async {
                operationAttempts++;
                throw Exception('Persistent failure');
              },
            );
          },
        );
      } on MaxRetriesExceededException {
        // Expected after circuit opens
      }

      expect(breaker.isOpen, isTrue);
      // Circuit should open before retry exhaustion
      expect(operationAttempts, lessThanOrEqualTo(5));
    });

    test('circuit recovers after timeout in half-open', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 1,
          successThreshold: 1,
          timeout: const Duration(milliseconds: 50),
        ),
      );
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 10),
        ),
      );

      // Open the circuit
      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 60));
      expect(breaker.canAttemptRequest(), isTrue);
      expect(breaker.isHalfOpen, isTrue);

      // Succeed in half-open state
      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          return breaker.execute<String>(
            operationName: 'wrapped_op',
            operation: () async => 'success',
          );
        },
      );

      expect(result.success, isTrue);
      expect(breaker.isClosed, isTrue);
    });

    test('failed health check keeps circuit open', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 1,
          successThreshold: 1,
          timeout: const Duration(milliseconds: 50),
        ),
      );

      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      await Future.delayed(const Duration(milliseconds: 60));
      breaker.canAttemptRequest(); // Trigger transition to half-open
      expect(breaker.isHalfOpen, isTrue);

      // Fail in half-open state
      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      // Should still be open, not half-open
      expect(breaker.canAttemptRequest(), isFalse);
    });

    test('integration tracks combined statistics', () async {
      final breaker = CircuitBreaker();
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
        ),
      );

      // Successful execution
      await executor.execute<String>(
        operationName: 'op1',
        operation: () async {
          return breaker.execute<String>(
            operationName: 'op1_wrapped',
            operation: () async => 'success',
          );
        },
      );

      final stats = breaker.getStats();
      expect(stats.totalRequests, equals(1));
      expect(stats.successfulRequests, equals(1));
      expect(stats.successRate, equals(100.0));
    });

    test('retries with status code filtering', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
          retryableStatusCodes: [500, 503],
        ),
      );

      var statusCode = 500;

      try {
        await executor.execute<String>(
          operationName: 'test_op',
          operation: () async => throw Exception('Server error'),
          getStatusCode: () => statusCode,
        );
      } catch (e) {
        // Expected
      }

      // Status code 404 should not retry
      statusCode = 404;

      expect(
        () => executor.execute<String>(
          operationName: 'test_op',
          operation: () async => throw Exception('Not found'),
          getStatusCode: () => statusCode,
        ),
        throwsA(isA<MaxRetriesExceededException>()),
      );
    });

    test('circuit breaker with exponential backoff', () async {
      final breaker = CircuitBreaker();
      final executor = RetryExecutor(
        policy: RetryPolicy(
          initialDelay: const Duration(milliseconds: 20),
          useJitter: false,
        ),
      );

      var attemptCount = 0;
      final startTime = DateTime.now();

      try {
        await executor.execute<String>(
          operationName: 'test_op',
          operation: () async {
            return breaker.execute<String>(
              operationName: 'wrapped_op',
              operation: () async {
                attemptCount++;
                throw Exception('Fail');
              },
            );
          },
        );
      } catch (e) {
        // Expected
      }

      final duration = DateTime.now().difference(startTime);
      expect(attemptCount, equals(4)); // 1 initial + 3 retries
      // Should have significant delay due to backoff
      expect(duration.inMilliseconds, greaterThan(50));
    });

    test('fallback value on retry exhaustion', () async {
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 5),
        ),
      );

      final result = await executor.executeWithFallback<String>(
        operationName: 'test_op',
        operation: () async => throw Exception('Fail'),
        fallbackValue: 'fallback',
      );

      expect(result, equals('fallback'));
    });

    test('timeout handling in retry + circuit breaker', () async {
      final breaker = CircuitBreaker();
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 10),
        ),
      );

      var attemptCount = 0;

      try {
        await executor.execute<String>(
          operationName: 'test_op',
          operation: () async {
            return breaker.execute<String>(
              operationName: 'wrapped_op',
              operation: () async {
                attemptCount++;
                throw TimeoutException('Timeout');
              },
            );
          },
        );
      } catch (e) {
        // Expected
      }

      expect(attemptCount, equals(2)); // Initial + 1 retry
      expect(breaker.isOpen, isFalse); // Circuit should record the failure
    });

    test('comprehensive error scenario', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 3,
          successThreshold: 1,
          timeout: const Duration(milliseconds: 100),
        ),
      );
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
          retryableStatusCodes: [500, 503],
        ),
      );

      // Simulate failures leading to circuit open
      for (var i = 0; i < 3; i++) {
        try {
          await executor.execute<String>(
            operationName: 'test_op',
            operation: () async {
              return breaker.execute<String>(
                operationName: 'wrapped_op',
                operation: () async => throw Exception('Error'),
              );
            },
          );
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.isOpen, isTrue);

      // Wait for recovery
      await Future.delayed(const Duration(milliseconds: 120));

      // Should recover
      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          return breaker.execute<String>(
            operationName: 'wrapped_op',
            operation: () async => 'recovered',
          );
        },
      );

      expect(result.success, isTrue);
      expect(result.data, equals('recovered'));
      expect(breaker.isClosed, isTrue);
    });

    test('multiple circuit breakers independently managed', () async {
      final breaker1 = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 2),
      );
      final breaker2 = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 2),
      );
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 5),
        ),
      );

      // Open breaker1
      breaker1.recordFailure();
      breaker1.recordFailure();
      expect(breaker1.isOpen, isTrue);
      expect(breaker2.isClosed, isTrue);

      // breaker2 still works
      final result = await executor.execute<String>(
        operationName: 'test_op',
        operation: () async {
          return breaker2.execute<String>(
            operationName: 'wrapped_op',
            operation: () async => 'success',
          );
        },
      );

      expect(result.success, isTrue);
      expect(breaker2.getStats().totalRequests, equals(1));
    });

    test('statistics consistency across retry and circuit breaker', () async {
      final breaker = CircuitBreaker();
      final executor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
        ),
      );

      // Multiple operations
      for (var i = 0; i < 3; i++) {
        try {
          await executor.execute<String>(
            operationName: 'op_$i',
            operation: () async {
              return breaker.execute<String>(
                operationName: 'wrapped_op_$i',
                operation: () async => 'result_$i',
              );
            },
          );
        } catch (e) {
          // Expected in some cases
        }
      }

      final stats = breaker.getStats();
      expect(stats.totalRequests, equals(3));
      expect(stats.successfulRequests, equals(3));
      expect(stats.successRate, equals(100.0));
    });
  });
}
