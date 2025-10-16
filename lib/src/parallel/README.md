# Parallel Request Manager - Quick Start Guide

## Installation

The Parallel Request Manager is included in the wordpress_client package:

```dart
import 'package:wordpress_client/src/parallel/parallel_request_manager.dart';
```

## Quick Start

### 1. Create a Manager

```dart
final manager = ParallelRequestManager(
  config: ParallelRequestConfig(
    maxConcurrentRequests: 5,
    requestTimeout: const Duration(seconds: 30),
    enablePriorityQueue: true,
    enableDeduplication: true,
  ),
);
```

### 2. Enqueue Requests

```dart
// Simple request
final result = await manager.enqueue<String>(
  id: 'request_1',
  execute: () async => 'Hello World',
);

// With priority
await manager.enqueue<void>(
  id: 'critical_task',
  priority: RequestPriority.critical,
  execute: () async => doSomethingCritical(),
);

// With metadata
await manager.enqueue<User>(
  id: 'get_user_123',
  priority: RequestPriority.high,
  metadata: {'userId': '123', 'cache': true},
  execute: () async => fetchUser('123'),
);
```

### 3. Wait for Completion

```dart
// Wait for all requests
await manager.waitAll();

// Get statistics
final stats = manager.getStats();
print('Success: ${stats.successfulRequests}');
print('Failed: ${stats.failedRequests}');
print('Success Rate: ${stats.successRate}%');
```

## Common Patterns

### Batch Processing

```dart
// Process multiple items with priority
for (int i = 0; i < items.length; i++) {
  await manager.enqueue<Result>(
    id: 'item_$i',
    priority: i == 0 ? RequestPriority.critical : RequestPriority.normal,
    execute: () async => processItem(items[i]),
  );
}

await manager.waitAll();
```

### Error Handling

```dart
// Errors are tracked but not rethrown
await manager.enqueue<void>(
  id: 'risky_op',
  execute: () async {
    throw Exception('Something went wrong');
  },
);

await manager.waitAll();

final stats = manager.getStats();
if (stats.failedRequests > 0) {
  print('Had ${stats.failedRequests} failures');
}
```

### Cancellation

```dart
// Queue a long task
manager.enqueue<void>(
  id: 'long_task',
  execute: () async => await longRunningOperation(),
);

// Cancel it if needed
if (manager.cancel('long_task')) {
  print('Task cancelled');
}

// Or cancel everything
final count = manager.cancelAll();
print('Cancelled $count requests');
```

### Deduplication

```dart
// Both requests share the same result
final future1 = manager.enqueue<User>(
  id: 'user_123',
  execute: () async => fetchUser('123'),
);

final future2 = manager.enqueue<User>(
  id: 'user_123', // Same ID!
  execute: () async => fetchUser('123'),
);

// Only one actual network call happens
final user = await future1; // First waiter gets result
final samUser = await future2; // Gets cached result
```

## Priority Levels

| Priority   | Use Case                 | Execution Order |
| ---------- | ------------------------ | --------------- |
| `critical` | Authentication, security | First (0)       |
| `high`     | User-facing operations   | Second (1)      |
| `normal`   | Background tasks         | Third (2)       |
| `low`      | Analytics, logging       | Last (3)        |

## Configuration Options

```dart
ParallelRequestConfig(
  // How many requests can execute simultaneously
  // Default: 5, Adjust for your resource constraints
  maxConcurrentRequests: 5,

  // How long to wait before timing out a request
  // Default: 30 seconds
  requestTimeout: const Duration(seconds: 30),

  // Reorder queue by priority before processing
  // Default: true, set false to disable
  enablePriorityQueue: true,

  // Return cached result for duplicate request IDs
  // Default: true, set false to always execute
  enableDeduplication: true,
)
```

## Statistics

The `getStats()` method returns an object with:

```dart
final stats = manager.getStats();

// Counts
stats.totalRequests         // Total enqueued
stats.successfulRequests    // Completed successfully
stats.failedRequests        // Failed/errored
stats.cancelledRequests     // Cancelled before execution

// Percentages
stats.successRate           // % successful (0-100)
stats.failureRate           // % failed (0-100)
```

## Results Management

```dart
// Get all results
final results = manager.getResults();
for (final result in results) {
  print('${result.requestId}: ${result.durationMs}ms');
}

// Clear results (keeps statistics)
manager.clearResults();

// Shutdown (cleanup)
await manager.shutdown();
```

## Best Practices

### ✅ DO

- Use meaningful request IDs for debugging
- Set appropriate timeout for your use case
- Adjust `maxConcurrentRequests` based on resources
- Use priority for business-critical operations
- Check statistics after batch operations
- Call `shutdown()` when done

### ❌ DON'T

- Enqueue blocking operations (they'll starve the queue)
- Set very low max concurrent (will be slow)
- Ignore errors (check statistics)
- Share managers across isolates (not thread-safe)
- Expect persistent results (cleared on shutdown)

## Troubleshooting

### All Requests Timing Out

**Problem**: Requests consistently timeout after X seconds

**Solution**:

- Increase `requestTimeout` if operations legitimately take longer
- Check if network/server is slow
- Reduce `maxConcurrentRequests` if rate-limited

### Low Success Rate

**Problem**: Many requests are failing

**Solution**:

- Check `getResults()` for error details
- Verify request logic with single sequential request
- Check network/API status
- Review error statistics

### Requests Not Executing

**Problem**: Queued requests don't seem to run

**Solution**:

- Call `waitAll()` to ensure processing
- Check `queuedCount` and `executingCount` properties
- Verify `execute` function doesn't have blocking code
- Review timeout settings

### Memory Usage Growing

**Problem**: Memory increases with many requests

**Solution**:

- Call `clearResults()` periodically
- Use smaller batch sizes
- Increase timeout to process faster
- Consider distributed processing

## Example: Real-World Use Case

```dart
// Fetch multiple posts with priority and error handling
final manager = ParallelRequestManager(
  config: ParallelRequestConfig(
    maxConcurrentRequests: 5,
    enablePriorityQueue: true,
  ),
);

try {
  // High priority: get featured posts
  await manager.enqueue<Post>(
    id: 'featured_posts',
    priority: RequestPriority.high,
    execute: () => wordpress.getPosts(featured: true),
  );

  // Normal priority: get recent posts
  for (int i = 0; i < 10; i++) {
    manager.enqueue<Post>(
      id: 'post_$i',
      priority: RequestPriority.normal,
      execute: () => wordpress.getPost(i),
    );
  }

  // Low priority: prefetch comments
  manager.enqueue<List<Comment>>(
    id: 'comments',
    priority: RequestPriority.low,
    execute: () => wordpress.getComments(),
  );

  // Wait for all
  await manager.waitAll();

  // Check results
  final stats = manager.getStats();
  if (stats.failedRequests > 0) {
    print('Warning: ${stats.failedRequests} requests failed');
  }

  final results = manager.getResults();
  for (final result in results) {
    if (result.success) {
      print('✓ ${result.requestId} (${result.durationMs}ms)');
    } else {
      print('✗ ${result.requestId}: ${result.error}');
    }
  }
} finally {
  await manager.shutdown();
}
```

## API Reference

### Methods

| Method           | Returns        | Purpose             |
| ---------------- | -------------- | ------------------- |
| `enqueue()`      | `Future<T>`    | Queue request       |
| `cancel(id)`     | `bool`         | Cancel pending      |
| `cancelAll()`    | `int`          | Cancel all pending  |
| `waitAll()`      | `Future<void>` | Wait for completion |
| `getStats()`     | `dynamic`      | Get statistics      |
| `getResults()`   | `List<...>`    | Get all results     |
| `clearResults()` | `void`         | Clear result cache  |
| `shutdown()`     | `Future<void>` | Cleanup             |

### Properties

| Property         | Returns | Purpose           |
| ---------------- | ------- | ----------------- |
| `queuedCount`    | `int`   | Pending requests  |
| `executingCount` | `int`   | Currently running |

## Limits & Constraints

- **Max queue size**: Limited by available memory
- **Max concurrent**: Configurable (default 5)
- **Timeout**: Configurable (default 30s)
- **Threads**: Single-threaded (Dart event loop)
- **Isolation**: Single isolate only

## Performance

Typical throughput with default config (5 concurrent):

- **CPU-bound tasks**: 100s-1000s per second
- **I/O-bound tasks**: 10s-100s per second
- **Network requests**: 1s-10s per second
- **Mixed workload**: Depends on task distribution

## Support

For issues or questions:

1. Check the documentation in `FEATURE_5_COMPLETE.md`
2. Review test examples in `test/parallel/parallel_request_manager_test.dart`
3. Check WordPress Client main documentation

## License

Part of wordpress_client package. See LICENSE file.
