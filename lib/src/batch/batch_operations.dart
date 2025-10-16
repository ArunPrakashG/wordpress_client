import 'dart:async';

import '../requests/wordpress_request.dart';
import '../responses/wordpress_response.dart';
import 'batch_interface.dart';

/// Implementation of a batch operation.
final class _BatchOperation<T> implements IBatchOperation<T> {
  _BatchOperation({
    required this.id,
    required this.request,
  }) : state = BatchOperationState.pending;
  @override
  final String id;

  @override
  final WordpressRequest request;

  @override
  BatchOperationState state;

  @override
  WordpressResponse<T>? response;

  @override
  Exception? error;

  @override
  DateTime? startTime;

  @override
  DateTime? endTime;

  /// Tracks if this operation was cancelled during execution
  /// This is used to preserve the cancelled state even if the operation completes
  bool _wasCancelled = false;

  @override
  bool get isSuccess =>
      state == BatchOperationState.completed &&
      response is WordpressSuccessResponse<T>;

  @override
  bool get isFailed => state == BatchOperationState.failed || error != null;

  @override
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  void markExecuting() {
    state = BatchOperationState.executing;
    startTime = DateTime.now();
  }

  void markCompleted(WordpressResponse<T> result) {
    // Don't change state if already cancelled
    if (_wasCancelled) {
      return;
    }
    state = BatchOperationState.completed;
    response = result;
    endTime = DateTime.now();
  }

  void markFailed(Exception err) {
    // Don't change state if already cancelled
    if (_wasCancelled) {
      return;
    }
    state = BatchOperationState.failed;
    error = err;
    endTime = DateTime.now();
  }

  void markCancelled() {
    _wasCancelled = true;
    state = BatchOperationState.cancelled;
    endTime = DateTime.now();
  }
}

/// Implementation of batch request builder and executor.
final class BatchRequestImpl implements IBatchRequest {
  BatchRequestImpl({
    BatchConfig? config,
    Future<WordpressResponse> Function(WordpressRequest)? executor,
  })  : config = config ?? const BatchConfig(),
        _executor = executor;
  @override
  final BatchConfig config;

  final Map<String, _BatchOperation> _operations = {};
  final List<_BatchOperation> _executionOrder = [];
  final StreamController<(int, int)> _progressController =
      StreamController<(int, int)>.broadcast();

  /// Callback to execute individual requests
  /// Must be provided by the client integrating batch operations
  final Future<WordpressResponse> Function(WordpressRequest)? _executor;

  bool _executing = false;
  Completer<void>? _cancelCompleter;

  @override
  int get operationCount => _operations.length;

  @override
  IBatchRequest add(WordpressRequest request, {String? operationId}) {
    if (_executing) {
      throw StateError('Cannot add operations to batch during execution');
    }

    final id = operationId ?? 'op_${_operations.length + 1}';
    if (_operations.containsKey(id)) {
      throw ArgumentError('Operation with id "$id" already exists');
    }

    final operation = _BatchOperation<dynamic>(id: id, request: request);
    _operations[id] = operation;
    _executionOrder.add(operation);

    return this;
  }

  @override
  IBatchRequest addRaw(WordpressRequest request, {String? operationId}) {
    return add(request, operationId: operationId);
  }

  @override
  IBatchRequest remove(String operationId) {
    if (_executing) {
      throw StateError('Cannot remove operations from batch during execution');
    }

    _operations.remove(operationId);
    _executionOrder.removeWhere((op) => op.id == operationId);

    return this;
  }

  @override
  IBatchRequest clear() {
    if (_executing) {
      throw StateError('Cannot clear batch during execution');
    }

    _operations.clear();
    _executionOrder.clear();

    return this;
  }

  @override
  Stream<(int, int)> get progressStream => _progressController.stream;

  @override
  IBatchOperation? getOperation(String operationId) => _operations[operationId];

  @override
  List<IBatchOperation> get operations =>
      List<IBatchOperation>.unmodifiable(_executionOrder);

  @override
  Future<BatchResponse> execute() async {
    if (_executing) {
      throw StateError('Batch is already executing');
    }

    if (_operations.isEmpty) {
      throw StateError('Batch has no operations to execute');
    }

    if (_executor == null) {
      throw StateError(
        'Batch executor not configured. Provide an executor function via constructor',
      );
    }

    _executing = true;
    _cancelCompleter = Completer<void>();

    final startTime = DateTime.now();
    final responses = <WordpressResponse>[];
    final failedOps = <_BatchOperation>[];
    Exception? thrownException;

    try {
      if (config.atomic) {
        // Atomic execution: all or nothing
        responses.addAll(await _executeAtomic(failedOps));
      } else {
        // Non-atomic execution: continue on errors
        responses.addAll(await _executeNonAtomic(failedOps));
      }
    } catch (e) {
      thrownException = e is Exception ? e : Exception(e.toString());
    } finally {
      _executing = false;
      if (!_cancelCompleter!.isCompleted) {
        _cancelCompleter?.complete();
      }
      await _progressController.close();
    }

    final endTime = DateTime.now();
    final totalDuration = endTime.difference(startTime);

    // If there was an exception in atomic mode, rethrow it
    if (thrownException != null) {
      throw thrownException;
    }

    return BatchResponse(
      responses: responses,
      operations: _executionOrder,
      totalDuration: totalDuration,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<WordpressResponse>> _executeAtomic(
    List<_BatchOperation> failedOps,
  ) async {
    final responses = <WordpressResponse>[];

    try {
      // Mark all operations as executing at start
      for (final op in _executionOrder) {
        op.markExecuting();
      }

      // Execute in parallel with maxConcurrent limit
      final opsToExecute = [..._executionOrder];
      while (opsToExecute.isNotEmpty) {
        if (_cancelCompleter?.isCompleted ?? false) {
          // Mark remaining operations as cancelled
          for (final op in opsToExecute) {
            if (op.state == BatchOperationState.executing) {
              op.markCancelled();
            }
          }
          break;
        }

        // Apply operation timeout if configured
        Future<WordpressResponse> executeWithTimeout(_BatchOperation op) {
          final future = _executeOperation(op);

          if (config.operationTimeout != null) {
            return future.timeout(
              config.operationTimeout!,
              onTimeout: () {
                final timeoutError = TimeoutException(
                  'Operation ${op.id} exceeded timeout',
                  config.operationTimeout,
                );
                op.markFailed(Exception(timeoutError.toString()));
                throw timeoutError;
              },
            );
          }

          return future;
        }

        // Determine how many operations to execute concurrently
        final batchSize = config.maxConcurrent ?? opsToExecute.length;
        final batch = opsToExecute.take(batchSize).toList();
        opsToExecute.removeRange(0, batch.length);

        // Execute batch concurrently with fail-fast semantics
        final futures = batch.map(executeWithTimeout);
        final results = await Future.wait(
          futures,
          eagerError: true, // Fail fast for atomic execution
        ).onError<Object>((error, stackTrace) async {
          // Mark all as failed on atomic failure
          for (final op in _executionOrder) {
            if (op.state == BatchOperationState.executing ||
                op.state == BatchOperationState.pending) {
              op.markFailed(Exception('$error'));
            }
          }
          throw error;
        });

        responses.addAll(results);

        // Check for failures (either exceptions or failure responses)
        for (var i = 0; i < batch.length; i++) {
          final op = batch[i];
          final response = results[i];

          if (response is WordpressFailureResponse) {
            op.markFailed(
                Exception('HTTP ${response.code}: ${response.error}'));
            failedOps.add(op);
          } else if (op.isFailed) {
            failedOps.add(op);
          }
        }

        // In atomic mode, fail immediately on any failure
        if (failedOps.isNotEmpty) {
          await _rollback(responses, failedOps);
          throw BatchOperationException(
            message: 'Atomic batch failed, operations rolled back',
            failedOperations: failedOps,
            rolledBackOperations: _executionOrder,
            rolledBack: true,
          );
        }

        // Update progress
        _progressController.add((responses.length, operationCount));
      }
    } catch (e) {
      // Mark all pending as failed on error
      for (final op in _executionOrder) {
        if (op.state == BatchOperationState.executing ||
            op.state == BatchOperationState.pending) {
          op.markFailed(e is Exception ? e : Exception(e.toString()));
        }
      }
      rethrow;
    }

    return responses;
  }

  Future<List<WordpressResponse>> _executeNonAtomic(
    List<_BatchOperation> failedOps,
  ) async {
    final responses = <WordpressResponse>[];

    // Execute operations respecting maxConcurrent and continueOnError
    final opsToExecute = [..._executionOrder];
    while (opsToExecute.isNotEmpty) {
      // Check for cancellation before processing next batch
      if (_cancelCompleter?.isCompleted ?? false) {
        // Mark all remaining operations as cancelled
        for (final op in opsToExecute) {
          if (op.state == BatchOperationState.pending) {
            op.markCancelled();
          }
        }
        break;
      }

      final batchSize = config.maxConcurrent ?? opsToExecute.length;
      final batch = opsToExecute.take(batchSize).toList();
      opsToExecute.removeRange(0, batch.length);

      // Build futures with proper error handling
      final futures = <Future<WordpressResponse?>>[];
      for (final op in batch) {
        var future = _executeOperation(op).then<WordpressResponse?>((response) {
          // Check if execution was cancelled while this was running
          if (response is WordpressFailureResponse) {
            final error = Exception('HTTP ${response.code}: ${response.error}');
            op.markFailed(error);
            failedOps.add(op);
            if (!config.continueOnError) {
              throw error;
            }
          }
          return response;
        }).onError<Object>((error, stackTrace) {
          if (config.continueOnError) {
            failedOps.add(op);
            // Return null for failed operation when continuing
            return null as WordpressResponse?;
          }
          // Re-throw if not continuing on error
          throw error;
        });

        // Apply timeout if configured
        if (config.operationTimeout != null) {
          future = future.timeout(
            config.operationTimeout!,
            onTimeout: () {
              op.markFailed(
                TimeoutException(
                  'Operation ${op.id} exceeded timeout',
                  config.operationTimeout,
                ),
              );
              failedOps.add(op);
              if (config.continueOnError) {
                return null;
              }
              throw TimeoutException(
                'Operation ${op.id} exceeded timeout',
                config.operationTimeout,
              );
            },
          );
        }

        futures.add(future);
      }

      // Wait for all futures in this batch
      final results = await Future.wait<WordpressResponse?>(futures);

      // Add non-null responses, but skip if operation was cancelled
      for (var i = 0; i < batch.length; i++) {
        final op = batch[i];
        final result = results[i];

        // Skip adding responses for cancelled operations
        if (op.state == BatchOperationState.cancelled) {
          continue;
        }

        if (result != null) {
          responses.add(result);
        }
      }

      _progressController.add((responses.length, operationCount));
    }

    return responses;
  }

  Future<WordpressResponse> _executeOperation(_BatchOperation op) async {
    if (_executor == null) {
      throw StateError('No executor configured for batch operations');
    }

    op.markExecuting();

    try {
      // Execute the request through the provided executor
      final response = await _executor!(op.request);
      op.markCompleted(response);
      return response;
    } catch (e) {
      final err = e is Exception ? e : Exception(e.toString());
      op.markFailed(err);
      rethrow;
    }
  }

  Future<void> _rollback(
    List<WordpressResponse> responses,
    List<_BatchOperation> failedOps,
  ) async {
    // Rollback logic based on strategy
    switch (config.rollbackStrategy) {
      case RollbackStrategy.none:
        // No rollback
        break;

      case RollbackStrategy.rollbackAll:
        // Mark all operations as cancelled (rolled back)
        for (final op in _executionOrder) {
          if (op.state != BatchOperationState.failed) {
            op.markCancelled();
          }
        }
        break;

      case RollbackStrategy.rollbackFailed:
        // Mark only failed operations as cancelled
        for (final op in failedOps) {
          op.markCancelled();
        }
        break;
    }
  }

  @override
  Future<void> cancel() async {
    if (!_executing) return;

    if (!(_cancelCompleter?.isCompleted ?? true)) {
      _cancelCompleter?.complete();
    }

    // Mark all pending/executing operations as cancelled
    for (final op in _executionOrder) {
      if (op.state == BatchOperationState.pending ||
          op.state == BatchOperationState.executing) {
        op.markCancelled();
      }
    }

    // Wait for current execution to complete
    var attempts = 0;
    while (_executing && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 10));
      attempts++;
    }
  }
}
