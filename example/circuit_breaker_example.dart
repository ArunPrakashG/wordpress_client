/// Example: Circuit Breaker Pattern (Feature 6 - Phase 2)
///
/// This example demonstrates the CircuitBreaker implementation for
/// protecting against cascading failures in distributed systems.
///
/// Features:
/// - Three-state machine: Closed (healthy), Open (failing), Half-Open (testing)
/// - Automatic state transitions
/// - Request rejection when open
/// - Recovery testing
/// - Detailed statistics

import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  print('═════════════════════════════════════════════════════');
  print('Feature 6 - Phase 2: Circuit Breaker Pattern Example');
  print('═════════════════════════════════════════════════════\n');

  // =========================================================================
  // BASIC: Simple circuit breaker with default configuration
  // =========================================================================
  print('1️⃣ Basic Circuit Breaker');
  print('────────────────────────\n');

  try {
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(),
    );

    print(
        '   State: ${breaker.isClosed ? "Closed (healthy)" : "Open (failing)"}');
    print('   Failure threshold: 5');
    print('   Success threshold: 2');
    print('   Timeout: 60 seconds\n');

    await breaker.execute(
      operationName: 'posts_endpoint',
      operation: () => client.posts.list(ListPostRequest()),
    );

    print('✅ Request succeeded');
    print(
        '   Breaker state: ${breaker.isClosed ? "Closed" : breaker.isOpen ? "Open" : "Half-Open"}');
    print('   Circuit state: ${breaker.state}\n');
  } on CircuitOpenException catch (e) {
    print('⚠️ Circuit breaker is open: $e\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // STATE MACHINE: Understand the three states
  // =========================================================================
  print('2️⃣ Circuit Breaker States');
  print('─────────────────────────\n');

  print('   Closed (healthy state):');
  print('   - Requests pass through to the service');
  print('   - Failures are counted');
  print('   - When failures exceed threshold → transition to Open\n');

  print('   Open (failing state):');
  print('   - Requests are immediately rejected');
  print('   - Prevents cascading failures downstream');
  print('   - After timeout duration → transition to Half-Open\n');

  print('   Half-Open (testing state):');
  print('   - Limited requests allowed through');
  print('   - Testing if service has recovered');
  print('   - If successful → transition to Closed');
  print('   - If failed → transition back to Open\n');

  // =========================================================================
  // STATE TRANSITIONS: Monitor state changes
  // =========================================================================
  print('3️⃣ State Transitions');
  print('───────────────────\n');

  try {
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      ),
    );

    print('   Initial state: ${breaker.isClosed ? "Closed" : "Open"}');
    print('   Current state value: ${breaker.state}\n');

    // Simulate successful request
    try {
      await breaker.execute(
        operationName: 'test_request',
        operation: () => client.posts.list(ListPostRequest(perPage: 5)),
      );
      print('   After success: State=${breaker.state}\n');
    } catch (e) {
      print('   Request error: $e\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // FAILURE THRESHOLD: Transition to Open state
  // =========================================================================
  print('4️⃣ Failure Threshold & State Transition');
  print('──────────────────────────────────────\n');

  try {
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 2, // Transition to Open after 2 failures
        timeout: const Duration(seconds: 30),
      ),
    );

    print('   Configuration:');
    print('   - Failure threshold: 2');
    print('   - Success threshold: 2');
    print('   - Timeout: 30 seconds\n');

    print('   Scenario:');
    print('   1. First failure → state = Closed');
    print('   2. Second failure → state = Open (threshold reached)');
    print('   3. Further requests rejected immediately\n');

    // Simulate requests with potential failures
    for (var i = 0; i < 5; i++) {
      try {
        await breaker.execute(
          operationName: 'test_$i',
          operation: () => client.posts.extensions.getById(i + 1),
        );
        print('   Request $i: ✅ Success, state=${breaker.state}');
      } on CircuitOpenException {
        print('   Request $i: ⚠️ Circuit Open, rejected');
        break;
      } catch (e) {
        print('   Request $i: ❌ Error, state=${breaker.state}');
      }
    }

    print('\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // RECOVERY: Success threshold and recovery logic
  // =========================================================================
  print('5️⃣ Recovery & Half-Open State');
  print('──────────────────────────────\n');

  try {
    // Example showing circuit breaker configuration (not used here)
    print('   Configuration:');
    print('   - Failure threshold: 2 (transition to Open)');
    print('   - Success threshold: 2 (transition to Closed)');
    print('   - Timeout: 5 seconds (time in Open before Half-Open)\n');

    print('   Recovery process:');
    print('   1. Failures push circuit to threshold');
    print('   2. Circuit transitions to Open');
    print('   3. After 5 second timeout → Half-Open');
    print('   4. Next request is allowed through (test)');
    print('   5. If success, need 1 more success to fully close');
    print('   6. If failure, circuit opens again\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // TIMEOUT: Wait duration before retesting
  // =========================================================================
  print('6️⃣ Timeout Configuration');
  print('─────────────────────────\n');

  try {
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(
        failureThreshold: 3,
        timeout:
            const Duration(seconds: 30), // Wait 30 seconds before retesting
      ),
    );

    print('   Configuration:');
    print('   - Timeout: 30 seconds');
    print('   - Meaning: After circuit opens, wait 30s before Half-Open\n');

    print('   Why timeout matters:');
    print('   - Gives failing service time to recover');
    print('   - Prevents immediate retry storms');
    print('   - Allows dependent services to stabilize');
    print('   - Typical values: 30-60 seconds for APIs\n');

    await breaker.execute(
      operationName: 'tested_fetch',
      operation: () => client.media.list(ListMediaRequest(perPage: 5)),
    );

    print('✅ Request completed successfully\n');
  } on CircuitOpenException catch (e) {
    print('⚠️ Circuit breaker open: $e\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // STATISTICS: Monitor circuit health
  // =========================================================================
  print('7️⃣ Circuit Health Statistics');
  print('────────────────────────────\n');

  try {
    final breaker = CircuitBreaker(
      config: CircuitBreakerConfig(),
    );

    // Make multiple requests
    for (var i = 0; i < 3; i++) {
      try {
        await breaker.execute(
          operationName: 'metric_fetch_$i',
          operation: () => client.comments.list(ListCommentRequest(perPage: 5)),
        );
      } catch (e) {
        // Ignore errors for this example
      }
    }

    print('   Circuit Statistics:');
    print(
        '   - State: ${breaker.isClosed ? "Closed (healthy)" : breaker.isOpen ? "Open (unhealthy)" : "Half-Open (testing)"}');
    print('   - Circuit state: ${breaker.state}');
    print('   - Is closed: ${breaker.isClosed}');
    print('   - Is open: ${breaker.isOpen}');
    print('   - Is half-open: ${breaker.isHalfOpen}');
    print('   - Failure threshold: 5');
    print('   - Success threshold: 2\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // COMBINED WITH RETRY: Best practice pattern
  // =========================================================================
  print('8️⃣ Combined Retry + Circuit Breaker');
  print('─────────────────────────────────────\n');

  try {
    // Example showing both retry executor and circuit breaker configurations
    print('   Retry Configuration:');
    print('   - Max retries: 2');
    print('   - Initial delay: 100ms');
    print('   - Backoff multiplier: 2.0\n');

    print('   Circuit Breaker Configuration:');
    print('   - Failure threshold: 5');
    print('   - Success threshold: 2');
    print('   - Timeout: 60 seconds\n');

    print('   How it works:');
    print('   1. Request comes in');
    print('   2. Circuit breaker checks if open');
    print('   3. If closed, retry executor attempts request');
    print('   4. Retry executor retries on transient failures');
    print('   5. After threshold, circuit breaker opens');
    print('   6. Further requests rejected immediately\n');

    // This pattern is shown in the integrated_resilience_example.dart
    print('   Benefits:');
    print('   - Handles transient failures (retry logic)');
    print('   - Protects against cascading failures (circuit breaker)');
    print('   - Optimal for production systems\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // BEST PRACTICES & TUNING
  // =========================================================================
  print('📋 Best Practices & Tuning');
  print('──────────────────────────\n');

  print('✓ Set failure threshold based on acceptable error rate');
  print('✓ Tune success threshold for recovery confidence');
  print('✓ Use appropriate timeout (30-60s typical for APIs)');
  print('✓ Monitor circuit state transitions in production');
  print('✓ Combine with retry logic for optimal resilience');
  print('✓ Log circuit state changes for debugging');
  print('✓ Alert on repeated circuit open events\n');

  print('Tuning Guidelines:');
  print('─────────────────');
  print('- failure_threshold: 3-10 (how many failures before opening)');
  print('- success_threshold: 1-3 (how many successes to fully close)');
  print('- timeout: 30-120 seconds (how long before retesting)');
  print('- For critical services: use lower thresholds, longer timeout');
  print(
      '- For non-critical services: use higher thresholds, shorter timeout\n');

  client.dispose();
  print('═════════════════════════════════════════════════════');
  print('Example completed successfully!');
  print('═════════════════════════════════════════════════════');
}
