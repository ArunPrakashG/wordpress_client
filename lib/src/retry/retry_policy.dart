/// Retry policy for configuring retry behavior
class RetryPolicy {
  RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 100),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
    this.jitterPercentage = 0.1,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptions = const [],
    this.retryOnTimeout = true,
  });

  /// Maximum number of retry attempts (total attempts = maxRetries + 1)
  final int maxRetries;

  /// Initial delay between retries
  final Duration initialDelay;

  /// Maximum delay between retries (for exponential backoff)
  final Duration maxDelay;

  /// Multiplier for exponential backoff (e.g., 2.0 for doubling)
  final double backoffMultiplier;

  /// Whether to add random jitter to delays
  final bool useJitter;

  /// Jitter percentage (0.0-1.0, default 0.1 = 10%)
  final double jitterPercentage;

  /// HTTP status codes to retry on (e.g., [408, 429, 500, 502, 503, 504])
  final List<int> retryableStatusCodes;

  /// Exception types to retry on (empty = retry all)
  final List<Type> retryableExceptions;

  /// Whether to retry on timeout
  final bool retryOnTimeout;

  /// Get delay for a specific attempt number
  Duration getDelayForAttempt(int attemptNumber) {
    if (attemptNumber <= 1) return initialDelay;

    // Calculate exponential backoff: initialDelay * (backoffMultiplier ^ (attemptNumber - 1))
    final multiplier = backoffMultiplier * (attemptNumber - 1);
    var delay = (initialDelay.inMilliseconds * multiplier).toInt();

    // Cap at maximum delay
    if (delay > maxDelay.inMilliseconds) {
      delay = maxDelay.inMilliseconds;
    }

    // Add jitter if enabled
    if (useJitter && delay > 0) {
      final jitterAmount = (delay * jitterPercentage).toInt();
      if (jitterAmount > 0) {
        final random = DateTime.now().millisecondsSinceEpoch % jitterAmount;
        delay = delay + random;
      }
    }

    return Duration(milliseconds: delay);
  }

  /// Check if exception should be retried
  bool shouldRetry(Exception exception, int statusCode) {
    // Check status code
    if (statusCode != -1 && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    // Check exception type
    if (retryableExceptions.isEmpty) {
      // Retry all exceptions by default
      return true;
    }

    for (final exceptionType in retryableExceptions) {
      if (exception.runtimeType == exceptionType) {
        return true;
      }
    }

    return false;
  }

  /// Create a copy with modified values
  RetryPolicy copyWith({
    int? maxRetries,
    Duration? initialDelay,
    Duration? maxDelay,
    double? backoffMultiplier,
    bool? useJitter,
    double? jitterPercentage,
    List<int>? retryableStatusCodes,
    List<Type>? retryableExceptions,
    bool? retryOnTimeout,
  }) {
    return RetryPolicy(
      maxRetries: maxRetries ?? this.maxRetries,
      initialDelay: initialDelay ?? this.initialDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      useJitter: useJitter ?? this.useJitter,
      jitterPercentage: jitterPercentage ?? this.jitterPercentage,
      retryableStatusCodes: retryableStatusCodes ?? this.retryableStatusCodes,
      retryableExceptions: retryableExceptions ?? this.retryableExceptions,
      retryOnTimeout: retryOnTimeout ?? this.retryOnTimeout,
    );
  }
}
