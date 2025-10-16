/// Example: Error Recovery with Retry Logic (Feature 6 - Phase 1)
///
/// This example demonstrates how to use RetryExecutor with RetryPolicy
/// for automatic error recovery with exponential backoff and jitter.
///
/// Features:
/// - Configurable retry attempts
/// - Exponential backoff with jitter
/// - Status code filtering
/// - Detailed retry statistics

import 'dart:async';

import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  print('═════════════════════════════════════════════════════');
  print('Feature 6 - Phase 1: Retry Logic Example');
  print('═════════════════════════════════════════════════════\n');

  // =========================================================================
  // BASIC: Simple retry with default configuration
  // =========================================================================
  print('1️⃣ Basic Retry with Default Configuration');
  print('──────────────────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 100),
      ),
    );

    final result = await executor.execute(
      operationName: 'fetch_posts',
      operation: () => client.posts.list(ListPostRequest(perPage: 5)),
    );

    print('✅ Request completed');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Duration: ${result.stats.durationMs}ms');
    print('   Success rate: ${result.stats.successRate.toStringAsFixed(1)}%');
    print('   Success: ${result.success}\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // EXPONENTIAL BACKOFF: Increasing delay between retries
  // =========================================================================
  print('2️⃣ Exponential Backoff Configuration');
  print('────────────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 4,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0, // Each retry waits 2x longer
        maxDelay: Duration(seconds: 5), // Cap maximum delay
      ),
    );

    print('   Retry delays (exponential):');
    print('   Attempt 1: immediately');
    print('   Attempt 2: ~100ms');
    print('   Attempt 3: ~200ms');
    print('   Attempt 4: ~400ms');
    print('   Attempt 5: ~800ms (capped at 5s)\n');

    final result = await executor.execute(
      operationName: 'fetch_media',
      operation: () => client.media.list(ListMediaRequest(perPage: 10)),
    );

    print('✅ Request succeeded with exponential backoff');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Duration: ${result.stats.durationMs}ms');
    print('   Success: ${result.success}\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // JITTER: Randomized backoff to prevent thundering herd
  // =========================================================================
  print('3️⃣ Jitter for Distributed Load');
  print('────────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        useJitter: true, // Add randomness to delays
        jitterPercentage: 0.2, // 20% jitter
      ),
    );

    print('   Configuration:');
    print('   - Jitter enabled: 20% randomization');
    print('   - Prevents synchronized retries in distributed systems');
    print('   - Better load distribution on servers\n');

    final result = await executor.execute(
      operationName: 'fetch_comments',
      operation: () => client.comments.list(ListCommentRequest(perPage: 5)),
    );

    print('✅ Request succeeded with jitter');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Duration: ${result.stats.durationMs}ms\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // STATUS CODE FILTERING: Only retry on specific HTTP status codes
  // =========================================================================
  print('4️⃣ Selective Retry by Status Code');
  print('──────────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 100),
        // Only retry on transient failures (5xx errors and specific 4xx)
        retryableStatusCodes: [
          408, // Request Timeout
          429, // Too Many Requests
          500, // Internal Server Error
          502, // Bad Gateway
          503, // Service Unavailable
          504, // Gateway Timeout
        ],
      ),
    );

    print('   Will retry on status codes:');
    print('   - 408: Request Timeout');
    print('   - 429: Too Many Requests');
    print('   - 5xx: Server errors (500-599)');
    print('   Will NOT retry on:');
    print('   - 400: Bad Request');
    print('   - 401: Unauthorized');
    print('   - 404: Not Found\n');

    final result = await executor.execute(
      operationName: 'fetch_pages',
      operation: () => client.pages.list(ListPageRequest(perPage: 10)),
    );

    print('✅ Request succeeded with status code filtering');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Success: ${result.success}\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // TIMEOUT HANDLING: Retry on timeout
  // =========================================================================
  print('5️⃣ Timeout Handling');
  print('───────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 2,
        initialDelay: Duration(milliseconds: 100),
        retryOnTimeout: true, // Retry on timeout exceptions
      ),
    );

    print('   Configuration:');
    print('   - Retry on timeout: enabled');
    print('   - Max retries: 2');
    print('   - Initial delay: 100ms\n');

    final result = await executor.execute(
      operationName: 'fetch_categories',
      operation: () => client.categories.list(ListCategoryRequest(perPage: 10)),
    );

    print('✅ Request completed with timeout handling');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Duration: ${result.stats.durationMs}ms\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // ERROR TRACKING: Detailed error information
  // =========================================================================
  print('6️⃣ Error Tracking & Statistics');
  print('───────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 2,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
      ),
    );

    final result = await executor.execute(
      operationName: 'tracked_fetch',
      operation: () => client.tags.list(ListTagRequest(perPage: 10)),
    );

    print('✅ Operation completed');
    print('   Total attempts: ${result.stats.totalAttempts}');
    print('   Successful attempts: ${result.stats.successfulAttempts}');
    print('   Failed attempts: ${result.stats.failedAttempts}');
    print('   Success rate: ${result.stats.successRate.toStringAsFixed(1)}%');
    print(
        '   Delays applied: ${result.stats.delays.map((d) => '${d.inMilliseconds}ms').join(', ')}');
    print('   Duration: ${result.stats.durationMs}ms\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // PRODUCTION-READY CONFIGURATION
  // =========================================================================
  print('7️⃣ Production-Ready Configuration');
  print('──────────────────────────────────\n');

  try {
    final executor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 5, // Try up to 6 times total
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        maxDelay: Duration(seconds: 10),
        useJitter: true,
        jitterPercentage: 0.15,
        retryableStatusCodes: [
          408,
          429,
          500,
          502,
          503,
          504,
        ],
        retryOnTimeout: true,
      ),
    );

    print('   Configuration:');
    print('   - Max attempts: 6');
    print('   - Initial delay: 100ms');
    print('   - Backoff multiplier: 2.0x');
    print('   - Max delay: 10 seconds');
    print('   - Jitter: enabled (15%)');
    print('   - Retryable status codes: 408, 429, 5xx');
    print('   - Retry on timeout: enabled\n');

    final result = await executor.execute(
      operationName: 'resilient_fetch',
      operation: () => client.posts.list(ListPostRequest(perPage: 20)),
    );

    print('✅ Production request completed');
    print('   Attempts: ${result.stats.totalAttempts}');
    print('   Duration: ${result.stats.durationMs}ms');
    print('   Success: ${result.success}\n');
  } catch (e) {
    print('❌ Request failed: $e\n');
  }

  // =========================================================================
  // BEST PRACTICES & TIMING
  // =========================================================================
  print('📋 Best Practices');
  print('─────────────────\n');

  print('✓ Use exponential backoff to avoid overwhelming the server');
  print('✓ Enable jitter in distributed systems (multiple clients)');
  print('✓ Set reasonable retry limits (2-5 retries typical)');
  print('✓ Configure status code filters (only retry transient errors)');
  print('✓ Enable timeout retries for slow/unstable connections');
  print('✓ Set max delay to prevent excessive waiting');
  print('✓ Monitor retry statistics for tuning\n');

  print('⏱️ Typical Retry Timeline (5 retries, 100ms initial, 2x backoff)');
  print('────────────────────────────────────────────────────────────────');
  print('Attempt 1: 0ms');
  print('Attempt 2: 100ms');
  print('Attempt 3: 300ms (100 + 200)');
  print('Attempt 4: 700ms (300 + 400)');
  print('Attempt 5: 1500ms (700 + 800)');
  print('Attempt 6: 3100ms (1500 + 1600)');
  print('Maximum total duration: ~3.1 seconds\n');

  client.dispose();
  print('═════════════════════════════════════════════════════');
  print('Example completed successfully!');
  print('═════════════════════════════════════════════════════');
}
