import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';

/// Represents the state of individual operations within a batch.
enum BatchOperationState {
  /// Operation is pending execution
  pending,

  /// Operation is currently executing
  executing,

  /// Operation completed successfully
  completed,

  /// Operation failed with error
  failed,

  /// Operation was cancelled
  cancelled,
}

/// Represents a single operation within a batch request.
abstract interface class IBatchOperation<T> {
  /// Unique identifier for this operation within the batch.
  String get id;

  /// The underlying request to execute.
  WordpressRequest get request;

  /// Current state of this operation.
  BatchOperationState get state;

  /// The response for this operation, if completed.
  WordpressResponse<T>? get response;

  /// Error that occurred during execution, if failed.
  Exception? get error;

  /// Whether this operation completed successfully.
  bool get isSuccess =>
      state == BatchOperationState.completed &&
      response is WordpressSuccessResponse<T>;

  /// Whether this operation failed.
  bool get isFailed => state == BatchOperationState.failed || error != null;

  /// When this operation started executing.
  DateTime? get startTime;

  /// When this operation finished executing.
  DateTime? get endTime;

  /// Duration of execution.
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }
}

/// Rollback strategy for atomic batch operations.
enum RollbackStrategy {
  /// Don't rollback on failure
  none,

  /// Rollback all operations if any fails (atomic)
  rollbackAll,

  /// Rollback only failed operations, keep successful ones
  rollbackFailed,
}

/// Configuration for batch execution.
final class BatchConfig {
  const BatchConfig({
    this.atomic = false,
    this.rollbackStrategy = RollbackStrategy.none,
    this.maxConcurrent,
    this.timeout,
    this.operationTimeout,
    this.continueOnError = false,
    this.preserveOrder = true,
  });

  /// Whether batch should be atomic (all-or-nothing)
  final bool atomic;

  /// Rollback strategy if atomic batch fails
  final RollbackStrategy rollbackStrategy;

  /// Maximum concurrent operations to execute
  final int? maxConcurrent;

  /// Timeout for entire batch execution
  final Duration? timeout;

  /// Timeout per individual operation
  final Duration? operationTimeout;

  /// Whether to continue if individual operations fail
  final bool continueOnError;

  /// Whether to preserve operation order
  final bool preserveOrder;
}

/// Response from a batch execution.
final class BatchResponse {
  BatchResponse({
    required this.responses,
    required this.operations,
    required this.totalDuration,
    required this.startTime,
    required this.endTime,
  });

  /// All operation responses in original order
  final List<WordpressResponse> responses;

  /// Individual operations with their results
  final List<IBatchOperation> operations;

  /// Total duration of batch execution
  final Duration totalDuration;

  /// Timestamp when batch started
  final DateTime startTime;

  /// Timestamp when batch completed
  final DateTime endTime;

  /// Whether all operations succeeded
  bool get allSuccess => responses.every((r) => r is WordpressSuccessResponse);

  /// Whether any operation failed
  bool get hasErrors => responses.any((r) => r is WordpressFailureResponse);

  /// Number of successful operations
  int get successCount =>
      responses.whereType<WordpressSuccessResponse>().length;

  /// Number of failed operations
  int get failureCount =>
      responses.whereType<WordpressFailureResponse>().length;

  /// Failed responses
  List<WordpressFailureResponse> get failures =>
      responses.whereType<WordpressFailureResponse>().toList();

  /// Successful responses
  List<WordpressSuccessResponse> get successes =>
      responses.whereType<WordpressSuccessResponse>().toList();

  /// Get result at specific index
  WordpressResponse? operator [](int index) {
    if (index < 0 || index >= responses.length) return null;
    return responses[index];
  }

  @override
  String toString() => '''BatchResponse(
    total: ${responses.length},
    success: $successCount,
    failed: $failureCount,
    duration: $totalDuration,
  )''';
}

/// Interface for building and executing batch requests.
abstract interface class IBatchRequest {
  /// Configuration for this batch
  BatchConfig get config;

  /// Number of operations in batch
  int get operationCount;

  /// Add a request to the batch
  IBatchRequest add(WordpressRequest request, {String? operationId});

  /// Add a raw WordPress request to the batch
  IBatchRequest addRaw(WordpressRequest request, {String? operationId});

  /// Remove operation by ID
  IBatchRequest remove(String operationId);

  /// Clear all operations
  IBatchRequest clear();

  /// Execute the batch and return results
  Future<BatchResponse> execute();

  /// Cancel ongoing execution
  Future<void> cancel();

  /// Get progress stream for monitoring batch execution
  Stream<(int completed, int total)> get progressStream;

  /// Get operation by ID
  IBatchOperation? getOperation(String operationId);

  /// List all operations
  List<IBatchOperation> get operations;
}

/// Exception thrown during batch operation execution
final class BatchOperationException implements Exception {
  BatchOperationException({
    required this.message,
    this.operationId,
    this.cause,
    this.failedOperations = const [],
    this.rolledBackOperations = const [],
    this.rolledBack = false,
  });

  /// Error message
  final String message;

  /// Which operation failed
  final String? operationId;

  /// Underlying error, if any
  final Exception? cause;

  /// Operations that failed
  final List<IBatchOperation> failedOperations;

  /// Operations that were rolled back
  final List<IBatchOperation> rolledBackOperations;

  /// Whether rollback occurred
  final bool rolledBack;

  @override
  String toString() {
    final parts = ['BatchOperationException: $message'];
    if (operationId != null) {
      parts.add('operation: $operationId');
    }
    if (failedOperations.isNotEmpty) {
      parts.add('failed: ${failedOperations.length}');
    }
    if (rolledBack) {
      parts.add('ROLLED BACK');
    }
    return parts.join(' | ');
  }
}
