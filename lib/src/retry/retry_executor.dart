import 'dart:async';

import 'retry_policy.dart';

/// Statistics for retry attempts
class RetryStats {
  RetryStats({
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.failedAttempts,
    required this.errors,
    required this.delays,
    required this.startTime,
    this.endTime,
  });
  final int totalAttempts;
  final int successfulAttempts;
  final int failedAttempts;
  final List<Exception> errors;
  final List<Duration> delays;
  final DateTime startTime;
  final DateTime? endTime;

  int get durationMs {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMilliseconds;
  }

  double get successRate =>
      totalAttempts == 0 ? 0.0 : (successfulAttempts / totalAttempts) * 100;
}

/// Result of a retry execution
class RetryResult<T> {
  RetryResult({
    required this.success,
    required this.stats,
    this.data,
    this.error,
  });
  final T? data;
  final Exception? error;
  final bool success;
  final RetryStats stats;
}

/// Exception thrown when max retries exceeded
class MaxRetriesExceededException implements Exception {
  MaxRetriesExceededException({
    required this.message,
    required this.stats,
    this.lastError,
  });
  final String message;
  final Exception? lastError;
  final RetryStats stats;

  @override
  String toString() => 'MaxRetriesExceededException: $message';
}

/// Retry executor with exponential backoff
class RetryExecutor {
  RetryExecutor({RetryPolicy? policy}) : policy = policy ?? RetryPolicy();
  final RetryPolicy policy;

  /// Execute a function with retry logic
  Future<RetryResult<T>> execute<T>({
    required Future<T> Function() operation,
    required String operationName,
    int Function()? getStatusCode,
  }) async {
    final startTime = DateTime.now();
    var attemptCount = 0;
    final errors = <Exception>[];
    final delays = <Duration>[];
    Exception? lastError;

    while (attemptCount <= policy.maxRetries) {
      try {
        attemptCount++;
        final result = await operation();

        return RetryResult<T>(
          data: result,
          success: true,
          stats: RetryStats(
            totalAttempts: attemptCount,
            successfulAttempts: 1,
            failedAttempts: attemptCount - 1,
            errors: errors,
            delays: delays,
            startTime: startTime,
            endTime: DateTime.now(),
          ),
        );
      } on TimeoutException catch (e) {
        lastError = e;
        errors.add(e);

        if (!policy.retryOnTimeout) {
          // Don't retry timeout if not configured
          throw MaxRetriesExceededException(
            message: 'Timeout on $operationName (retry disabled for timeouts)',
            lastError: e,
            stats: RetryStats(
              totalAttempts: attemptCount,
              successfulAttempts: 0,
              failedAttempts: attemptCount,
              errors: errors,
              delays: delays,
              startTime: startTime,
              endTime: DateTime.now(),
            ),
          );
        }

        if (attemptCount > policy.maxRetries) break;

        final delay = policy.getDelayForAttempt(attemptCount);
        delays.add(delay);
        await Future.delayed(delay);
      } on Exception catch (e) {
        lastError = e;
        errors.add(e);

        final statusCode = getStatusCode?.call() ?? -1;

        if (!policy.shouldRetry(e, statusCode)) {
          // Don't retry if not in retryable list
          throw MaxRetriesExceededException(
            message:
                'Request failed and is not retryable (status: $statusCode)',
            lastError: e,
            stats: RetryStats(
              totalAttempts: attemptCount,
              successfulAttempts: 0,
              failedAttempts: attemptCount,
              errors: errors,
              delays: delays,
              startTime: startTime,
              endTime: DateTime.now(),
            ),
          );
        }

        if (attemptCount > policy.maxRetries) break;

        final delay = policy.getDelayForAttempt(attemptCount);
        delays.add(delay);
        await Future.delayed(delay);
      }
    }

    // Max retries exceeded
    throw MaxRetriesExceededException(
      message: 'Max retries ($attemptCount) exceeded for $operationName',
      lastError: lastError,
      stats: RetryStats(
        totalAttempts: attemptCount,
        successfulAttempts: 0,
        failedAttempts: attemptCount,
        errors: errors,
        delays: delays,
        startTime: startTime,
        endTime: DateTime.now(),
      ),
    );
  }

  /// Execute with retry and return result (no exception)
  Future<T?> executeWithFallback<T>({
    required Future<T> Function() operation,
    required String operationName,
    T? fallbackValue,
    int Function()? getStatusCode,
  }) async {
    try {
      final result = await execute<T>(
        operation: operation,
        operationName: operationName,
        getStatusCode: getStatusCode,
      );
      return result.data;
    } on MaxRetriesExceededException {
      return fallbackValue;
    }
  }
}
