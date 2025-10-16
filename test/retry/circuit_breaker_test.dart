// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:test/test.dart';
import 'package:wordpress_client/src/retry/circuit_breaker.dart';

void main() {
  group('Circuit Breaker', () {
    test('canAttemptRequest() returns true when closed', () {
      final breaker = CircuitBreaker();
      expect(breaker.isClosed, isTrue);
      expect(breaker.canAttemptRequest(), isTrue);
    });

    test('opens after failure threshold exceeded', () {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 3),
      );

      for (var i = 0; i < 3; i++) {
        breaker.recordFailure();
      }

      expect(breaker.isOpen, isTrue);
      expect(breaker.canAttemptRequest(), isFalse);
    });

    test('rejects requests when open', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 1),
      );
      breaker.recordFailure();

      expect(breaker.isOpen, isTrue);

      expect(
        () async => breaker.execute<void>(
          operationName: 'test',
          operation: () async {},
        ),
        throwsA(isA<CircuitOpenException>()),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final stats = breaker.getStats();
      expect(stats.rejectedRequests, equals(1));
    });

    test('transitions to half-open after timeout', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 1,
          timeout: const Duration(milliseconds: 50),
        ),
      );
      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(breaker.canAttemptRequest(), isTrue);
      expect(breaker.isHalfOpen, isTrue);
    });

    test('closes after success threshold in half-open', () {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 1,
        ),
      );
      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      breaker.halfOpen();
      expect(breaker.isHalfOpen, isTrue);

      breaker.recordSuccess();
      expect(breaker.isHalfOpen, isTrue);

      breaker.recordSuccess();
      expect(breaker.isClosed, isTrue);
    });

    test('reopens on failure in half-open state', () {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 1),
      );
      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);

      breaker.halfOpen();
      expect(breaker.isHalfOpen, isTrue);

      breaker.recordFailure();
      expect(breaker.isOpen, isTrue);
    });

    test('tracks statistics correctly', () {
      final breaker = CircuitBreaker();

      breaker.recordSuccess();
      breaker.recordSuccess();
      breaker.recordFailure();

      final stats = breaker.getStats();
      expect(stats.totalRequests, equals(3));
      expect(stats.successfulRequests, equals(2));
      expect(stats.failedRequests, equals(1));
      expect(stats.rejectedRequests, equals(0));
      expect(stats.successRate, equals(66.66666666666666)); // 2/3
    });

    test('manually opens and closes circuit', () {
      final breaker = CircuitBreaker();
      expect(breaker.isClosed, isTrue);

      breaker.open();
      expect(breaker.isOpen, isTrue);

      breaker.close();
      expect(breaker.isClosed, isTrue);
    });

    test('executes successfully when closed', () async {
      final breaker = CircuitBreaker();

      final result = await breaker.execute<String>(
        operationName: 'test',
        operation: () async => 'success',
      );

      expect(result, equals('success'));
      final stats = breaker.getStats();
      expect(stats.successfulRequests, equals(1));
    });

    test('records rejection with circuit open exception', () async {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(
          failureThreshold: 1,
          timeout: const Duration(milliseconds: 50),
        ),
      );
      breaker.recordFailure();

      try {
        await breaker.execute<void>(
          operationName: 'test',
          operation: () async {},
        );
      } on CircuitOpenException catch (e) {
        expect(e.message, contains('Circuit breaker open'));
        expect(e.timeUntilRetry, greaterThan(Duration.zero));
      }

      final stats = breaker.getStats();
      expect(stats.rejectedRequests, equals(1));
    });

    test('resets statistics', () {
      final breaker = CircuitBreaker(
        config: CircuitBreakerConfig(failureThreshold: 1),
      );
      breaker.recordFailure();
      breaker.recordSuccess();

      var stats = breaker.getStats();
      expect(stats.totalRequests, equals(2));

      breaker.reset();
      stats = breaker.getStats();
      expect(stats.totalRequests, equals(0));
      expect(stats.successfulRequests, equals(0));
      expect(stats.failedRequests, equals(0));
      expect(breaker.isClosed, isTrue);
    });
  });
}
