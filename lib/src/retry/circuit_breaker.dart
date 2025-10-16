import 'dart:async';

/// Circuit breaker states
enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

/// Configuration for circuit breaker
class CircuitBreakerConfig {
  CircuitBreakerConfig({
    this.failureThreshold = 5,
    this.successThreshold = 2,
    this.timeout = const Duration(seconds: 60),
    this.trackByExceptionType = false,
  });

  /// Number of failures before opening circuit
  final int failureThreshold;

  /// Number of successes in half-open state before closing
  final int successThreshold;

  /// Duration to wait before half-opening from open state
  final Duration timeout;

  /// Whether to track by exception type or treat all exceptions the same
  final bool trackByExceptionType;

  CircuitBreakerConfig copyWith({
    int? failureThreshold,
    int? successThreshold,
    Duration? timeout,
    bool? trackByExceptionType,
  }) {
    return CircuitBreakerConfig(
      failureThreshold: failureThreshold ?? this.failureThreshold,
      successThreshold: successThreshold ?? this.successThreshold,
      timeout: timeout ?? this.timeout,
      trackByExceptionType: trackByExceptionType ?? this.trackByExceptionType,
    );
  }
}

/// Circuit breaker statistics
class CircuitBreakerStats {
  CircuitBreakerStats({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.rejectedRequests,
    required this.state,
    required this.stateChangedAt,
    this.lastFailureAt,
    this.lastSuccessAt,
  });
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int rejectedRequests;
  final CircuitBreakerState state;
  final DateTime stateChangedAt;
  final DateTime? lastFailureAt;
  final DateTime? lastSuccessAt;

  double get successRate =>
      totalRequests == 0 ? 0.0 : (successfulRequests / totalRequests) * 100;

  double get failureRate =>
      totalRequests == 0 ? 0.0 : (failedRequests / totalRequests) * 100;
}

/// Exception thrown when circuit is open
class CircuitOpenException implements Exception {
  CircuitOpenException({
    required this.message,
    required this.openedAt,
    required this.timeUntilRetry,
  });
  final String message;
  final DateTime openedAt;
  final Duration timeUntilRetry;

  @override
  String toString() =>
      'CircuitOpenException: $message (retry in ${timeUntilRetry.inSeconds}s)';
}

/// Circuit breaker for preventing cascading failures
class CircuitBreaker {
  CircuitBreaker({CircuitBreakerConfig? config})
      : config = config ?? CircuitBreakerConfig();
  final CircuitBreakerConfig config;
  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _rejectedRequests = 0;
  DateTime _stateChangedAt = DateTime.now();
  DateTime? _lastFailureAt;
  DateTime? _lastSuccessAt;

  CircuitBreakerState get state => _state;
  bool get isClosed => _state == CircuitBreakerState.closed;
  bool get isOpen => _state == CircuitBreakerState.open;
  bool get isHalfOpen => _state == CircuitBreakerState.halfOpen;

  /// Check if request is allowed
  bool canAttemptRequest() {
    if (_state == CircuitBreakerState.closed ||
        _state == CircuitBreakerState.halfOpen) {
      return true;
    }

    // Check if timeout elapsed for open state
    if (_state == CircuitBreakerState.open) {
      final timeSinceOpen = DateTime.now().difference(_stateChangedAt);
      if (timeSinceOpen >= config.timeout) {
        _transitionToHalfOpen();
        return true;
      }
      return false;
    }

    return false;
  }

  /// Record a successful request
  void recordSuccess() {
    _totalRequests++;
    _successfulRequests++;
    _lastSuccessAt = DateTime.now();

    if (_state == CircuitBreakerState.halfOpen) {
      _successCount++;
      if (_successCount >= config.successThreshold) {
        _transitionToClosed();
      }
    } else if (_state == CircuitBreakerState.closed) {
      _failureCount = 0;
      _successCount = 0;
    }
  }

  /// Record a failed request
  void recordFailure() {
    _totalRequests++;
    _failedRequests++;
    _lastFailureAt = DateTime.now();

    if (_state == CircuitBreakerState.halfOpen) {
      _transitionToOpen();
    } else if (_state == CircuitBreakerState.closed) {
      _failureCount++;
      if (_failureCount >= config.failureThreshold) {
        _transitionToOpen();
      }
    }
  }

  /// Record a rejected request (when circuit is open)
  void recordRejection() {
    _totalRequests++;
    _rejectedRequests++;
  }

  /// Manually open the circuit
  void open() {
    if (_state != CircuitBreakerState.open) {
      _transitionToOpen();
    }
  }

  /// Manually close the circuit
  void close() {
    if (_state != CircuitBreakerState.closed) {
      _transitionToClosed();
    }
  }

  /// Manually transition to half-open for testing
  void halfOpen() {
    if (_state != CircuitBreakerState.halfOpen) {
      _transitionToHalfOpen();
    }
  }

  /// Reset all statistics
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _rejectedRequests = 0;
    _stateChangedAt = DateTime.now();
    _lastFailureAt = null;
    _lastSuccessAt = null;
  }

  void _transitionToClosed() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _stateChangedAt = DateTime.now();
  }

  void _transitionToOpen() {
    _state = CircuitBreakerState.open;
    _failureCount = 0;
    _successCount = 0;
    _stateChangedAt = DateTime.now();
  }

  void _transitionToHalfOpen() {
    _state = CircuitBreakerState.halfOpen;
    _failureCount = 0;
    _successCount = 0;
    _stateChangedAt = DateTime.now();
  }

  /// Get current statistics
  CircuitBreakerStats getStats() {
    return CircuitBreakerStats(
      totalRequests: _totalRequests,
      successfulRequests: _successfulRequests,
      failedRequests: _failedRequests,
      rejectedRequests: _rejectedRequests,
      state: _state,
      stateChangedAt: _stateChangedAt,
      lastFailureAt: _lastFailureAt,
      lastSuccessAt: _lastSuccessAt,
    );
  }

  /// Execute with circuit breaker protection
  Future<T> execute<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    if (!canAttemptRequest()) {
      recordRejection();
      final timeUntilRetry =
          config.timeout - DateTime.now().difference(_stateChangedAt);
      throw CircuitOpenException(
        message: 'Circuit breaker open for $operationName',
        openedAt: _stateChangedAt,
        timeUntilRetry: timeUntilRetry,
      );
    }

    try {
      final result = await operation();
      recordSuccess();
      return result;
    } catch (e) {
      recordFailure();
      rethrow;
    }
  }
}
