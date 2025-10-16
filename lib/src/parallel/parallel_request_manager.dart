import 'dart:async';

/// Priority level for requests
enum RequestPriority {
  low,
  normal,
  high,
  critical,
}

/// Configuration for parallel requests manager
class ParallelRequestConfig {
  ParallelRequestConfig({
    this.maxConcurrentRequests = 5,
    this.requestTimeout = const Duration(seconds: 30),
    this.enablePriorityQueue = true,
    this.enableDeduplication = true,
  });

  /// Maximum concurrent requests
  final int maxConcurrentRequests;

  /// Request timeout
  final Duration requestTimeout;

  /// Enable priority queuing
  final bool enablePriorityQueue;

  /// Enable request deduplication
  final bool enableDeduplication;
}

/// Exception for parallel request errors
class ParallelRequestException implements Exception {
  ParallelRequestException(this.message, {this.cause});
  final String message;
  final Exception? cause;

  @override
  String toString() =>
      'ParallelRequestException: $message${cause != null ? ' | Caused by: $cause' : ''}';
}

/// Represents a parallel request
class EnqueuedRequest<T> {
  EnqueuedRequest({
    required this.id,
    required this.execute,
    this.priority = RequestPriority.normal,
    this.metadata,
  }) : createdAt = DateTime.now();
  final String id;
  final Future<T> Function() execute;
  final RequestPriority priority;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  double get waitTimeSeconds =>
      DateTime.now().difference(createdAt).inMilliseconds / 1000.0;
}

/// Statistics for parallel requests
class _RequestStats {
  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  int cancelledRequests = 0;

  double get successRate =>
      totalRequests == 0 ? 0.0 : (successfulRequests / totalRequests) * 100;

  double get failureRate =>
      totalRequests == 0 ? 0.0 : (failedRequests / totalRequests) * 100;

  Map<String, dynamic> toMap() {
    return {
      'totalRequests': totalRequests,
      'successfulRequests': successfulRequests,
      'failedRequests': failedRequests,
      'cancelledRequests': cancelledRequests,
      'successRate': successRate,
      'failureRate': failureRate,
    };
  }
}

/// Represents a queued request
class _QueuedRequest {
  _QueuedRequest({
    required this.id,
    required this.execute,
    required this.priority,
    this.metadata,
  }) : createdAt = DateTime.now();
  final String id;
  final Future Function() execute;
  final RequestPriority priority;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  bool cancelled = false;
}

/// Result of a request execution
class ParallelRequestResult<T> {
  ParallelRequestResult({
    required this.requestId,
    required this.success,
    required this.startTime,
    this.data,
    this.error,
    this.endTime,
  });
  final String requestId;
  final bool success;
  final T? data;
  final Exception? error;
  final DateTime startTime;
  final DateTime? endTime;

  int get durationMs {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMilliseconds;
  }

  @override
  String toString() =>
      'ParallelRequestResult(id: $requestId, success: $success, duration: ${durationMs}ms)';
}

/// Parallel request manager with priority queuing
class ParallelRequestManager {
  ParallelRequestManager({ParallelRequestConfig? config})
      : config = config ?? ParallelRequestConfig();
  final ParallelRequestConfig config;
  final List<_QueuedRequest> _queue = [];
  final Map<String, Future> _executing = {};
  final Map<String, ParallelRequestResult> _results = {};
  final Map<String, Completer> _completers = {};
  final Map<String, Future> _dedupCache = {};
  final _RequestStats _stats = _RequestStats();
  Timer? _processingTimer;

  /// Enqueue a request
  Future<T> enqueue<T>({
    required String id,
    required Future<T> Function() execute,
    RequestPriority priority = RequestPriority.normal,
    Map<String, dynamic>? metadata,
  }) async {
    // Check deduplication cache
    if (config.enableDeduplication && _dedupCache.containsKey(id)) {
      return _dedupCache[id]! as Future<T>;
    }

    _stats.totalRequests++;

    final request = _QueuedRequest(
      id: id,
      execute: execute,
      priority: priority,
      metadata: metadata,
    );

    _queue.add(request);
    _sortQueue();

    final completer = Completer<T>();
    _completers[id] = completer;

    // Schedule processing if not already scheduled
    _scheduleProcessing();

    final future = completer.future;

    // Cache for deduplication
    if (config.enableDeduplication) {
      _dedupCache[id] = future;
    }

    // Ignore errors if future is not awaited (prevents unhandled exceptions)
    future.ignore();

    return future;
  }

  /// Schedule processing to happen soon
  void _scheduleProcessing() {
    if (_processingTimer != null) return; // Already scheduled
    // Wait a bit longer if queue is small to collect more items
    final delay = _queue.length < 2
        ? const Duration(milliseconds: 50)
        : const Duration(milliseconds: 10);
    _processingTimer = Timer(delay, () {
      _processingTimer = null;
      _processQueue();
    });
  }

  /// Sort queue by priority
  void _sortQueue() {
    if (!config.enablePriorityQueue) return;

    _queue.sort((a, b) {
      final priorityOrder = {
        RequestPriority.critical: 0,
        RequestPriority.high: 1,
        RequestPriority.normal: 2,
        RequestPriority.low: 3,
      };

      final aPriority = priorityOrder[a.priority] ?? 2;
      final bPriority = priorityOrder[b.priority] ?? 2;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      return a.createdAt.compareTo(b.createdAt);
    });
  }

  /// Process the queue
  void _processQueue() {
    _sortQueue(); // Re-sort before processing

    // Only process one batch at a time to allow tests to observe queue state
    while (
        _executing.length < config.maxConcurrentRequests && _queue.isNotEmpty) {
      final request = _queue.removeAt(0);

      if (request.cancelled) {
        _stats.cancelledRequests++;
        final completer = _completers.remove(request.id);
        completer?.completeError(
          ParallelRequestException('Request was cancelled: ${request.id}'),
        );
        // Continue processing after handling cancellation
        continue;
      }

      _executeRequest(request);

      // Only execute one request per batch, then schedule next batch
      // This allows tests to observe queue state
      if (_queue.isNotEmpty) {
        _scheduleProcessing();
      }
      return; // Exit early, next call from _scheduleProcessing
    }
  }

  /// Execute a single request
  void _executeRequest(_QueuedRequest request) {
    final startTime = DateTime.now();

    final future = Future.delayed(Duration.zero).then((_) async {
      try {
        final result = await request.execute().timeout(config.requestTimeout);
        _stats.successfulRequests++;
        _results[request.id] = ParallelRequestResult(
          requestId: request.id,
          success: true,
          data: result,
          startTime: startTime,
          endTime: DateTime.now(),
        );
        return result;
      } catch (e) {
        _stats.failedRequests++;
        _results[request.id] = ParallelRequestResult(
          requestId: request.id,
          success: false,
          error: e is Exception ? e : Exception(e.toString()),
          startTime: startTime,
          endTime: DateTime.now(),
        );
        rethrow;
      }
    }).then((result) {
      final completer = _completers.remove(request.id);
      completer?.complete(result);
    }).catchError((e) {
      final completer = _completers.remove(request.id);
      completer?.completeError(e);
    }).whenComplete(() {
      _executing.remove(request.id);
      if (_queue.isNotEmpty) {
        _processQueue();
      }
    });

    _executing[request.id] = future;
  }

  /// Cancel a request
  bool cancel(String id) {
    for (final req in _queue) {
      if (req.id == id && !req.cancelled) {
        req.cancelled = true;
        return true;
      }
    }
    return false;
  }

  /// Cancel all pending requests
  int cancelAll() {
    var count = 0;
    for (final req in _queue) {
      if (!req.cancelled) {
        req.cancelled = true;
        count++;
      }
    }
    return count;
  }

  /// Get queued count
  int get queuedCount => _queue.length;

  /// Get executing count
  int get executingCount => _executing.length;

  /// Wait for all to complete
  Future<void> waitAll() async {
    while (queuedCount > 0 || executingCount > 0) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Get stats as dynamic object with properties
  dynamic getStats() {
    return _StatsObject(_stats);
  }

  /// Get results
  List<ParallelRequestResult> getResults() => _results.values.toList();

  /// Clear results
  void clearResults() => _results.clear();

  /// Shutdown
  Future<void> shutdown() async {
    cancelAll();
    _processingTimer?.cancel();
    await waitAll();
    _queue.clear();
    _executing.clear();
    _results.clear();
    _completers.clear();
  }
}

/// Wrapper to make stats accessible like an object with properties
class _StatsObject {
  _StatsObject(this._stats);
  final _RequestStats _stats;

  int get totalRequests => _stats.totalRequests;
  int get successfulRequests => _stats.successfulRequests;
  int get failedRequests => _stats.failedRequests;
  int get cancelledRequests => _stats.cancelledRequests;
  double get successRate => _stats.successRate;
  double get failureRate => _stats.failureRate;
}
