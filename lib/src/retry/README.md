# Retry Module - Error Recovery & Resilience

The retry module provides production-grade error recovery and resilience patterns for the WordPress Client library.

## Overview

The module consists of three components:

1. **RetryPolicy**: Configuration for retry behavior
2. **RetryExecutor**: Execution orchestrator with retry logic
3. **CircuitBreaker**: State machine to prevent cascading failures

## Components

### RetryPolicy

Configures retry behavior with exponential backoff and jitter.

```dart
final policy = RetryPolicy(
  maxRetries: 3,                                    // Maximum retry attempts
  initialDelay: Duration(milliseconds: 100),       // Base delay
  backoffMultiplier: 2.0,                          // Exponential multiplier
  useJitter: true,                                 // Add randomization
  jitterPercent: 10,                               // Jitter as % of delay
  retryableStatusCodes: [408, 429, 500, 502, 503], // Retryable HTTP codes
  retryableExceptions: [TimeoutException],         // Retryable exceptions
  retryOnTimeout: true,                            // Retry on timeout
);
```

**Key Features**:

- Exponential backoff: `delay = initialDelay × (multiplier ^ attempt)`
- Jitter to prevent thundering herd
- Status code filtering
- Exception type filtering
- Timeout configuration

### RetryExecutor

Executes operations with automatic retry logic.

```dart
final executor = RetryExecutor(policy: policy);

// Basic execution with retry
final result = await executor.execute<String>(
  operationName: 'fetch_posts',
  operation: () async => await wpClient.posts().list(),
);

if (result.success) {
  print('Success: ${result.data}');
  print('Attempts: ${result.stats.totalAttempts}');
  print('Delays: ${result.stats.delays}');
}

// With fallback value
final posts = await executor.executeWithFallback<List<Post>>(
  operationName: 'fetch_posts',
  operation: () async => await wpClient.posts().list(),
  fallbackValue: <Post>[],
);
```

**Result Object**:

- `success`: Whether operation succeeded
- `data`: Result data (or null if failed)
- `stats`: Detailed statistics
  - `totalAttempts`: Total attempts made
  - `successfulAttempts`: Successful attempts
  - `failedAttempts`: Failed attempts
  - `errors`: List of exceptions encountered
  - `delays`: List of delays between attempts

### CircuitBreaker

Prevents cascading failures using a three-state state machine.

```dart
final breaker = CircuitBreaker(
  config: CircuitBreakerConfig(
    failureThreshold: 5,              // Open after 5 failures
    successThreshold: 2,              // Close after 2 successes (in half-open)
    timeout: Duration(seconds: 60),   // Wait 60s before trying half-open
  ),
);

// Protected execution
final result = await breaker.execute<String>(
  operationName: 'api_call',
  operation: () async => await api.call(),
);

// State queries
print('Is Closed: ${breaker.isClosed}');     // Normal operation
print('Is Open: ${breaker.isOpen}');         // Failing, rejecting requests
print('Is Half-Open: ${breaker.isHalfOpen}'); // Testing recovery

// Statistics
final stats = breaker.getStats();
print('Success Rate: ${stats.successRate}%');
print('Total Requests: ${stats.totalRequests}');

// Manual control
breaker.open();      // Force open
breaker.close();     // Force close
breaker.halfOpen();  // Force half-open
breaker.reset();     // Reset statistics
```

**State Transitions**:

- **Closed** → **Open**: When failures ≥ `failureThreshold`
- **Open** → **Half-Open**: After `timeout` elapsed
- **Half-Open** → **Closed**: When successes ≥ `successThreshold`
- **Half-Open** → **Open**: On any failure

## Usage Patterns

### 1. Retry Only

```dart
final executor = RetryExecutor(
  policy: RetryPolicy(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 100),
  ),
);

try {
  final result = await executor.execute(
    operationName: 'fetch',
    operation: () => api.fetch(),
  );

  if (result.success) {
    print('Success after ${result.stats.totalAttempts} attempts');
  }
} catch (e) {
  print('Failed after all retries');
}
```

### 2. Circuit Breaker Only

```dart
final breaker = CircuitBreaker();

try {
  final result = await breaker.execute(
    operationName: 'api_call',
    operation: () => api.call(),
  );
} on CircuitOpenException {
  print('Circuit is open, request rejected');
}
```

### 3. Combined: Retry + Circuit Breaker

```dart
final executor = RetryExecutor(policy: policy);
final breaker = CircuitBreaker();

final result = await executor.execute(
  operationName: 'protected_fetch',
  operation: () async {
    return await breaker.execute(
      operationName: 'api_endpoint',
      operation: () => api.fetch(),
    );
  },
);
```

This pattern:

- Retries transient failures within the closed circuit
- Opens circuit after repeated failures
- Prevents retry storms when circuit is open
- Recovers automatically via half-open state

### 4. With Fallback

```dart
final posts = await executor.executeWithFallback(
  operationName: 'fetch_posts',
  operation: () => api.posts(),
  fallbackValue: [],  // Return empty list on failure
);
```

## Configuration Examples

### Aggressive Retry (Quick Recovery)

```dart
final policy = RetryPolicy(
  maxRetries: 5,
  initialDelay: Duration(milliseconds: 50),
  backoffMultiplier: 1.5,
  useJitter: true,
);
```

### Conservative Retry (Slow Backoff)

```dart
final policy = RetryPolicy(
  maxRetries: 2,
  initialDelay: Duration(seconds: 1),
  backoffMultiplier: 3.0,
  useJitter: false,
);
```

### Sensitive Circuit Breaker (Quick Open)

```dart
final breaker = CircuitBreaker(
  config: CircuitBreakerConfig(
    failureThreshold: 2,      // Open quickly
    successThreshold: 1,      // Close on first success
    timeout: Duration(seconds: 10),  // Try recovery quickly
  ),
);
```

### Tolerant Circuit Breaker (Slow Open)

```dart
final breaker = CircuitBreaker(
  config: CircuitBreakerConfig(
    failureThreshold: 10,     // Allow many failures
    successThreshold: 5,      // Need many successes to close
    timeout: Duration(minutes: 5),  // Wait long before trying
  ),
);
```

## Exception Handling

### MaxRetriesExceededException

Thrown when all retry attempts are exhausted:

```dart
try {
  await executor.execute(
    operationName: 'op',
    operation: () => api.call(),
  );
} on MaxRetriesExceededException catch (e) {
  print('All retries failed: $e');
}
```

### CircuitOpenException

Thrown when circuit breaker rejects a request:

```dart
try {
  await breaker.execute(
    operationName: 'op',
    operation: () => api.call(),
  );
} on CircuitOpenException catch (e) {
  print('Circuit open: $e');
  print('Time until retry: ${e.timeUntilRetry}');
}
```

## Best Practices

1. **Choose appropriate retry counts**

   - Use 2-3 retries for fast operations
   - Use 5+ retries for slow operations
   - Balance between reliability and latency

2. **Configure exponential backoff**

   - Use 1.5-2.0x multiplier for network calls
   - Higher multiplier = longer wait times
   - Add jitter to prevent thundering herd

3. **Set circuit breaker thresholds**

   - Failure threshold: 3-5 for sensitive services
   - Success threshold: 2-3 to verify recovery
   - Timeout: 30-60 seconds for most services

4. **Monitor statistics**

   - Check success rates regularly
   - Track failure patterns
   - Adjust configuration based on production metrics

5. **Use appropriate fallback values**
   - Return empty collections instead of null
   - Provide sensible defaults
   - Never hide failures (log them)

## Integration Example

```dart
class ResilientWordPressClient {
  final WordPressClient client;
  final RetryExecutor retryExecutor;
  final CircuitBreaker postsBreaker;
  final CircuitBreaker commentsBreaker;

  ResilientWordPressClient(this.client)
    : retryExecutor = RetryExecutor(
        policy: RetryPolicy(
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 100),
        ),
      ),
      postsBreaker = CircuitBreaker(),
      commentsBreaker = CircuitBreaker();

  Future<List<Post>> getPosts() async {
    return await retryExecutor.executeWithFallback(
      operationName: 'get_posts',
      operation: () => postsBreaker.execute(
        operationName: 'posts_endpoint',
        operation: () => client.posts().list(),
      ),
      fallbackValue: [],
    );
  }

  Future<List<Comment>> getComments(int postId) async {
    return await retryExecutor.executeWithFallback(
      operationName: 'get_comments',
      operation: () => commentsBreaker.execute(
        operationName: 'comments_endpoint',
        operation: () => client.comments().list(post: postId),
      ),
      fallbackValue: [],
    );
  }
}
```

## Performance Characteristics

- **Retry**: O(n) where n = number of attempts, dominated by delay time
- **Circuit Breaker**: O(1) state checks and transitions
- **Memory**: ~100 bytes per circuit breaker instance

## Testing

The module includes comprehensive tests:

- **retry_executor_test.dart**: 8 tests for retry logic
- **circuit_breaker_test.dart**: 11 tests for state machine
- **integration_test.dart**: 12 tests for combined usage

Run tests:

```bash
dart test test/retry/
```

## References

- [Retry Pattern](https://en.wikipedia.org/wiki/Retry)
- [Exponential Backoff](https://en.wikipedia.org/wiki/Exponential_backoff)
- [Circuit Breaker Pattern](https://en.wikipedia.org/wiki/Circuit_breaker_design_pattern)
- [Timeout and Retries](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)

---

**Status**: Production Ready ✅
