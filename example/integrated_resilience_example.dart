/// Example: Integrated Resilience Pattern (Feature 6 - Phase 3)
///
/// This example demonstrates combining retry logic with circuit breaker
/// for a production-ready resilience pattern that handles both transient
/// and persistent failures.
///
/// Combines:
/// - RetryExecutor for handling transient failures
/// - CircuitBreaker for protecting against cascading failures
/// - Complete end-to-end error recovery strategy

import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  print('═════════════════════════════════════════════════════════');
  print('Feature 6 - Phase 3: Integrated Resilience Example');
  print('═════════════════════════════════════════════════════════\n');

  // =========================================================================
  // BASIC: Retry + Circuit Breaker Pattern
  // =========================================================================
  print('1️⃣ Basic Retry + Circuit Breaker Pattern');
  print('───────────────────────────────────────\n');

  try {
    // Setup retry executor
    final retryExecutor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
      ),
    );

    // Setup circuit breaker
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 5,
        successThreshold: 2,
        timeout: Duration(seconds: 60),
      ),
    );

    print('   Retry configuration:');
    print('   - Max retries: 3');
    print('   - Initial delay: 100ms');
    print('   - Backoff multiplier: 2.0\n');

    print('   Circuit breaker configuration:');
    print('   - Failure threshold: 5');
    print('   - Success threshold: 2');
    print('   - Timeout: 60 seconds\n');

    // Make resilient request: breaker controls, retryExecutor retries
    try {
      final result = await retryExecutor.execute(
        operationName: 'resilient_fetch',
        operation: () => breaker.execute(
          operationName: 'posts',
          operation: () => client.posts.list(ListPostRequest(perPage: 10)),
        ),
      );

      print('✅ Request completed successfully');
      print('   Retry attempts: ${result.stats.totalAttempts}');
      print('   Duration: ${result.stats.durationMs}ms');
      print('   Success: ${result.success}\n');
    } on CircuitOpenException catch (e) {
      print('⚠️ Circuit breaker protection triggered: $e\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // FAILURE SCENARIOS: Different types of failures
  // =========================================================================
  print('2️⃣ Handling Different Failure Types');
  print('──────────────────────────────────\n');

  print('   Transient failures (retried):');
  print('   - Timeout errors: retried with backoff');
  print('   - HTTP 429 (Too Many Requests): retried with backoff');
  print('   - HTTP 503 (Service Unavailable): retried with backoff');
  print('   - Network errors: retried with backoff\n');

  print('   Persistent failures (circuit opens):');
  print('   - After 5 failures: circuit opens');
  print('   - Further requests rejected immediately');
  print('   - After 60s timeout: half-open (testing)');
  print('   - Test request attempts recovery\n');

  print('   Client errors (not retried):');
  print('   - HTTP 400 (Bad Request): failed immediately');
  print('   - HTTP 401 (Unauthorized): failed immediately');
  print('   - HTTP 404 (Not Found): failed immediately');
  print('   - Invalid request data: failed immediately\n');

  // =========================================================================
  // REQUEST FLOW: Step-by-step execution
  // =========================================================================
  print('3️⃣ Request Execution Flow');
  print('─────────────────────────\n');

  print('   Step 1: Check Circuit Breaker State');
  print('   └─ If OPEN: Throw CircuitOpenException immediately');
  print('   └─ If CLOSED or HALF_OPEN: Continue to Step 2\n');

  print('   Step 2: Attempt Request');
  print('   └─ Execute API request through client\n');

  print('   Step 3: Handle Response');
  print('   ├─ If SUCCESS: Record success, return data\n');

  print('   Step 4: On Failure, Check Retryable');
  print('   ├─ If NOT retryable (e.g., 400, 401): Fail');
  print('   ├─ If retryable (e.g., 503, timeout): Continue\n');

  print('   Step 5: Calculate Backoff Delay');
  print('   ├─ Formula: initialDelay * (backoffMultiplier ^ attemptCount)');
  print('   ├─ Add jitter: delay + random(0 to 20%)');
  print('   └─ Cap at maxDelay (10 seconds)\n');

  print('   Step 6: Retry or Exhaust');
  print('   ├─ If attempts < maxRetries: Retry from Step 2');
  print('   └─ If attempts >= maxRetries: Record failure\n');

  print('   Step 7: Circuit Breaker Recording');
  print('   ├─ On success: Reset failure count, record success');
  print('   └─ On failure: Increment failure count, check threshold\n');

  // =========================================================================
  // STATE MACHINE: Complete state transition model
  // =========================================================================
  print('4️⃣ Complete State Machine');
  print('──────────────────────────\n');

  print('   CLOSED state (initial):');
  print('   - Accepts all requests');
  print('   - Counts failures');
  print('   - On 5th failure → transition to OPEN\n');

  print('   OPEN state (failures exceeded):');
  print('   - Rejects all requests immediately');
  print('   - Prevents cascading failures');
  print('   - After 60 seconds → transition to HALF_OPEN\n');

  print('   HALF_OPEN state (testing recovery):');
  print('   - Allows limited requests through');
  print('   - On success: increment success counter');
  print('   - On 2nd success → transition to CLOSED');
  print('   - On 1st failure → transition back to OPEN\n');

  // =========================================================================
  // PRODUCTION CONFIGURATION: Optimized for real-world use
  // =========================================================================
  print('5️⃣ Production-Ready Configuration');
  print('────────────────────────────────\n');

  try {
    // Optimized for production WordPress APIs
    final productionRetry = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 5, // Up to 6 total attempts
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        maxDelay: Duration(seconds: 10),
        useJitter: true,
        jitterPercentage: 0.15, // 15% random jitter
        retryableStatusCodes: [
          408, // Request Timeout
          429, // Too Many Requests
          500, // Internal Server Error
          502, // Bad Gateway
          503, // Service Unavailable
          504, // Gateway Timeout
        ],
        retryOnTimeout: true,
      ),
    );

    final productionBreaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 5, // Open after 5 failures
        successThreshold: 3, // Require 3 successes to close
        timeout: Duration(minutes: 1), // 1 minute before retry
      ),
    );

    print('   Retry Configuration (for transient failures):');
    print('   - Max retries: 5 (total 6 attempts)');
    print('   - Initial delay: 100ms');
    print('   - Backoff: 2.0x exponential');
    print('   - Max delay: 10 seconds');
    print('   - Jitter: 15% randomization\n');

    print('   Circuit Breaker Configuration (for persistent failures):');
    print('   - Failure threshold: 5');
    print('   - Success threshold: 3');
    print('   - Timeout: 60 seconds\n');

    print('   Retry Timeline (5 retries):');
    print('   - Attempt 1: 0ms');
    print('   - Attempt 2: 100ms ± 15ms');
    print('   - Attempt 3: 300ms ± 45ms');
    print('   - Attempt 4: 700ms ± 105ms');
    print('   - Attempt 5: 1500ms ± 225ms');
    print('   - Attempt 6: 3100ms ± 465ms (capped at 10s)');
    print('   - Total: ~5.7 seconds maximum\n');

    // Example usage
    await productionRetry.execute(
      operationName: 'production_request',
      operation: () => productionBreaker.execute(
        operationName: 'api_call',
        operation: () => client.posts.list(ListPostRequest(perPage: 20)),
      ),
    );

    print('✅ Production request completed\n');
  } on CircuitOpenException catch (e) {
    print('⚠️ Circuit breaker protection: $e\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // MULTIPLE ENDPOINTS: Different breakers per endpoint
  // =========================================================================
  print('6️⃣ Multiple Endpoints with Separate Breakers');
  print('─────────────────────────────────────────────\n');

  try {
    // Create separate breakers for different endpoints
    final postsBreaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 5,
        successThreshold: 2,
        timeout: Duration(seconds: 60),
      ),
    );

    final mediaBreaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 5,
        successThreshold: 2,
        timeout: Duration(seconds: 60),
      ),
    );

    final retryExecutor = RetryExecutor(
      policy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
      ),
    );

    print('   Setup:');
    print('   - postsBreaker: Independent circuit for /posts');
    print('   - mediaBreaker: Independent circuit for /media');
    print('   - Shared retryExecutor: For retry logic\n');

    print('   Benefits:');
    print('   - Isolation: failure in one endpoint doesn\'t affect others');
    print('   - Granular control: tune each endpoint independently');
    print('   - Better observability: track failures per endpoint\n');

    // Execute requests with separate breakers
    try {
      await retryExecutor.execute(
        operationName: 'posts_call',
        operation: () => postsBreaker.execute(
          operationName: 'posts',
          operation: () => client.posts.list(ListPostRequest(perPage: 5)),
        ),
      );

      await retryExecutor.execute(
        operationName: 'media_call',
        operation: () => mediaBreaker.execute(
          operationName: 'media',
          operation: () => client.media.list(ListMediaRequest(perPage: 5)),
        ),
      );

      print('✅ Both endpoints succeeded independently\n');
    } on CircuitOpenException catch (e) {
      print('⚠️ Endpoint circuit open: $e\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // MONITORING & LOGGING: Production observability
  // =========================================================================
  print('7️⃣ Monitoring & Observability');
  print('──────────────────────────────\n');

  print('   Metrics to track:');
  print('   - Retry attempts: Count per operation');
  print('   - Circuit state changes: When open/closed/half-open');
  print('   - Success rate: Successful requests / total requests');
  print('   - Failure types: Count of different failures');
  print('   - Response times: With and without retries');
  print('   - Circuit open duration: Time between state changes\n');

  print('   Production logging:');
  print('   - INFO: Successful requests');
  print('   - WARN: Retries after transient failures');
  print('   - WARN: Circuit breaker state transitions');
  print('   - ERROR: Exhausted retries');
  print('   - ERROR: Circuit open rejections\n');

  // =========================================================================
  // TESTING PATTERNS: How to test resilience
  // =========================================================================
  print('8️⃣ Testing Resilience');
  print('─────────────────────\n');

  print('   Unit tests:');
  print('   - Test retry with max attempts');
  print('   - Test circuit breaker state transitions');
  print('   - Test backoff calculation with jitter');
  print('   - Test status code filtering\n');

  print('   Integration tests:');
  print('   - Simulate transient failures (timeouts)');
  print('   - Simulate persistent failures');
  print('   - Verify state machine transitions');
  print('   - Test combined retry + breaker\n');

  print('   Chaos engineering:');
  print('   - Randomly fail requests to test resilience');
  print('   - Introduce network delays');
  print('   - Test with degraded service (slow responses)');
  print('   - Verify graceful degradation\n');

  // =========================================================================
  // BEST PRACTICES
  // =========================================================================
  print('📋 Best Practices Summary');
  print('─────────────────────────\n');

  print('✓ Always use retry + circuit breaker together');
  print('✓ Use exponential backoff with jitter');
  print('✓ Set realistic thresholds based on your service');
  print('✓ Create separate breakers for different endpoints');
  print('✓ Log all failures and state transitions');
  print('✓ Monitor retry and circuit breaker metrics');
  print('✓ Tune timeouts for your use case');
  print('✓ Test resilience patterns thoroughly');
  print('✓ Document retry and circuit breaker configuration\n');

  print('⚡ Key Principles:');
  print('──────────────');
  print('1. FAIL FAST: Detect failures quickly');
  print('2. RECOVER QUICKLY: Use exponential backoff');
  print('3. PROTECT DOWNSTREAM: Use circuit breaker');
  print('4. GATHER DATA: Track all metrics');
  print('5. ALERT EARLY: Monitor state changes\n');

  client.dispose();
  print('═════════════════════════════════════════════════════════');
  print('Example completed successfully!');
  print('═════════════════════════════════════════════════════════');
}
