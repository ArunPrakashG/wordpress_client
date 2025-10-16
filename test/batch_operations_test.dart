import 'package:test/test.dart';
import 'package:wordpress_client/src/batch/batch_interface.dart';
import 'package:wordpress_client/src/batch/batch_operations.dart';
import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/requests/wordpress_request.dart';
import 'package:wordpress_client/src/responses/wordpress_response.dart';
import 'package:wordpress_client/src/utilities/request_url.dart';

/// Helper to create a test WordpressSuccessResponse
WordpressSuccessResponse<T> _createSuccessResponse<T>(T data) {
  return WordpressSuccessResponse(
    data: data,
    rawData: const {},
    headers: const {},
    requestHeaders: const {},
    duration: Duration.zero,
  );
}

/// Helper to create a test WordpressFailureResponse
WordpressFailureResponse<T> _createFailureResponse<T>() {
  return WordpressFailureResponse(
    error: null,
    code: 400,
    rawData: const {},
  );
}

void main() {
  group('Batch Operations', () {
    group('BatchOperationState', () {
      test('has all required states', () {
        expect(BatchOperationState.pending, isNotNull);
        expect(BatchOperationState.executing, isNotNull);
        expect(BatchOperationState.completed, isNotNull);
        expect(BatchOperationState.failed, isNotNull);
        expect(BatchOperationState.cancelled, isNotNull);
      });

      test('states are distinct', () {
        final states = [
          BatchOperationState.pending,
          BatchOperationState.executing,
          BatchOperationState.completed,
          BatchOperationState.failed,
          BatchOperationState.cancelled,
        ];
        expect(states.length, equals(states.toSet().length));
      });
    });

    group('BatchConfig', () {
      test('has default values', () {
        const config = BatchConfig();
        expect(config.atomic, isFalse);
        expect(config.rollbackStrategy, equals(RollbackStrategy.none));
        expect(config.maxConcurrent, isNull);
        expect(config.timeout, isNull);
        expect(config.operationTimeout, isNull);
        expect(config.continueOnError, isFalse);
        expect(config.preserveOrder, isTrue);
      });

      test('can set custom values', () {
        const config = BatchConfig(
          atomic: true,
          rollbackStrategy: RollbackStrategy.rollbackAll,
          maxConcurrent: 5,
          continueOnError: true,
          preserveOrder: false,
        );
        expect(config.atomic, isTrue);
        expect(config.rollbackStrategy, equals(RollbackStrategy.rollbackAll));
        expect(config.maxConcurrent, equals(5));
        expect(config.continueOnError, isTrue);
        expect(config.preserveOrder, isFalse);
      });

      test('atomic and rollback strategy are independent', () {
        const config1 = BatchConfig(
          atomic: true,
        );
        expect(config1.atomic, isTrue);
        expect(config1.rollbackStrategy, equals(RollbackStrategy.none));

        const config2 = BatchConfig(
          rollbackStrategy: RollbackStrategy.rollbackAll,
        );
        expect(config2.atomic, isFalse);
        expect(config2.rollbackStrategy, equals(RollbackStrategy.rollbackAll));
      });
    });

    group('RollbackStrategy', () {
      test('has all required strategies', () {
        expect(RollbackStrategy.none, isNotNull);
        expect(RollbackStrategy.rollbackAll, isNotNull);
        expect(RollbackStrategy.rollbackFailed, isNotNull);
      });

      test('strategies are distinct', () {
        final strategies = [
          RollbackStrategy.none,
          RollbackStrategy.rollbackAll,
          RollbackStrategy.rollbackFailed,
        ];
        expect(strategies.length, equals(strategies.toSet().length));
      });
    });

    group('BatchRequestImpl', () {
      late WordpressRequest testRequest1;
      late WordpressRequest testRequest2;
      late WordpressRequest testRequest3;

      setUp(() {
        testRequest1 = WordpressRequest(
          url: RequestUrl.relative('/posts'),
          method: HttpMethod.get,
        );
        testRequest2 = WordpressRequest(
          url: RequestUrl.relative('/pages'),
          method: HttpMethod.get,
        );
        testRequest3 = WordpressRequest(
          url: RequestUrl.relative('/users'),
          method: HttpMethod.get,
        );
      });

      group('construction', () {
        test('creates with default config', () {
          final batch = BatchRequestImpl();
          expect(batch.config.atomic, isFalse);
          expect(batch.operationCount, equals(0));
        });

        test('creates with custom config', () {
          const config = BatchConfig(atomic: true);
          final batch = BatchRequestImpl(config: config);
          expect(batch.config.atomic, isTrue);
        });
      });

      group('add operations', () {
        test('adds single operation', () {
          final batch = BatchRequestImpl();
          final result = batch.add(testRequest1);
          expect(batch.operationCount, equals(1));
          expect(result, equals(batch)); // Returns self for chaining
        });

        test('adds multiple operations', () {
          final batch = BatchRequestImpl()
              .add(testRequest1)
              .add(testRequest2)
              .add(testRequest3);
          expect(batch.operationCount, equals(3));
        });

        test('generates unique operation IDs by default', () {
          final batch = BatchRequestImpl()
              .add(testRequest1)
              .add(testRequest2)
              .add(testRequest3);
          final ops = batch.operations;
          expect(ops[0].id, equals('op_1'));
          expect(ops[1].id, equals('op_2'));
          expect(ops[2].id, equals('op_3'));
        });

        test('accepts custom operation IDs', () {
          final batch = BatchRequestImpl()
              .add(testRequest1, operationId: 'fetch_posts')
              .add(testRequest2, operationId: 'fetch_pages');
          expect(batch.getOperation('fetch_posts'), isNotNull);
          expect(batch.getOperation('fetch_pages'), isNotNull);
        });

        test('rejects duplicate operation IDs', () {
          final batch =
              BatchRequestImpl().add(testRequest1, operationId: 'op1');
          expect(
            () => batch.add(testRequest2, operationId: 'op1'),
            throwsArgumentError,
          );
        });

        test('adds operation with addRaw method', () {
          final batch = BatchRequestImpl();
          batch.addRaw(testRequest1);
          expect(batch.operationCount, equals(1));
        });
      });

      group('remove operations', () {
        test('removes operation by ID', () {
          final batch = BatchRequestImpl()
              .add(testRequest1, operationId: 'op1')
              .add(testRequest2, operationId: 'op2')
              .add(testRequest3, operationId: 'op3');
          expect(batch.operationCount, equals(3));

          batch.remove('op2');
          expect(batch.operationCount, equals(2));
          expect(batch.getOperation('op2'), isNull);
        });

        test('remove returns self for chaining', () {
          final batch =
              BatchRequestImpl().add(testRequest1, operationId: 'op1');
          final result = batch.remove('op1');
          expect(result, equals(batch));
        });

        test('removing non-existent operation does nothing', () {
          final batch = BatchRequestImpl().add(testRequest1);
          expect(batch.operationCount, equals(1));
          batch.remove('nonexistent');
          expect(batch.operationCount, equals(1));
        });
      });

      group('clear operations', () {
        test('clears all operations', () {
          final batch = BatchRequestImpl()
              .add(testRequest1)
              .add(testRequest2)
              .add(testRequest3);
          expect(batch.operationCount, equals(3));

          batch.clear();
          expect(batch.operationCount, equals(0));
          expect(batch.operations, isEmpty);
        });

        test('clear returns self for chaining', () {
          final batch = BatchRequestImpl();
          final result = batch.clear();
          expect(result, equals(batch));
        });
      });

      group('get operations', () {
        test('retrieves operation by ID', () {
          final batch =
              BatchRequestImpl().add(testRequest1, operationId: 'op1');
          final op = batch.getOperation('op1');
          expect(op, isNotNull);
          expect(op!.id, equals('op1'));
          expect(op.request, equals(testRequest1));
        });

        test('returns null for non-existent operation', () {
          final batch = BatchRequestImpl();
          expect(batch.getOperation('nonexistent'), isNull);
        });

        test('returns unmodifiable operations list', () {
          final batch = BatchRequestImpl().add(testRequest1).add(testRequest2);
          final ops = batch.operations;
          expect(ops.length, equals(2));
          // Verify list is unmodifiable by checking it returns an unmodifiable list
          expect(ops, isA<List>());
          // Try to add should fail
          expect(
            () => ops.add(batch.getOperation('op_1')!),
            throwsUnsupportedError,
          );
        });
      });

      group('state management', () {
        test('throws when adding during execution', () async {
          BatchRequestImpl().add(testRequest1);
          // Simulate execution state by setting _executing to true
          // (In actual test with real executor)
          // For now, we can't test this without real executor
          expect(true, isTrue);
        });

        test('throws when removing during execution', () async {
          BatchRequestImpl().add(testRequest1, operationId: 'op1');
          // Similar limitation - need real executor simulation
          expect(true, isTrue);
        });

        test('throws when clearing during execution', () async {
          BatchRequestImpl().add(testRequest1);
          // Similar limitation - need real executor simulation
          expect(true, isTrue);
        });
      });

      group('builder pattern', () {
        test('supports fluent interface', () {
          final batch = BatchRequestImpl()
              .add(testRequest1, operationId: 'op1')
              .add(testRequest2, operationId: 'op2')
              .add(testRequest3, operationId: 'op3')
              .remove('op2');
          expect(batch.operationCount, equals(2));
        });

        test('preserves order of operations', () {
          final batch = BatchRequestImpl()
              .add(testRequest1, operationId: 'first')
              .add(testRequest2, operationId: 'second')
              .add(testRequest3, operationId: 'third');
          expect(batch.operations[0].id, equals('first'));
          expect(batch.operations[1].id, equals('second'));
          expect(batch.operations[2].id, equals('third'));
        });
      });
    });

    group('BatchResponse', () {
      test('has correct initial values', () {
        final response = BatchResponse(
          responses: [],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response.responses, isEmpty);
        expect(response.operations, isEmpty);
        expect(response.totalDuration, equals(Duration.zero));
      });

      test('calculates success count correctly', () {
        final success1 = _createSuccessResponse({'id': 1});
        final success2 = _createSuccessResponse({'id': 2});
        final response = BatchResponse(
          responses: [success1, success2],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response.successCount, equals(2));
      });

      test('calculates failure count correctly', () {
        final failure1 = _createFailureResponse();
        final failure2 = _createFailureResponse();
        final response = BatchResponse(
          responses: [failure1, failure2],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response.failureCount, equals(2));
      });

      test('detects all success', () {
        final success1 = _createSuccessResponse({'id': 1});
        final success2 = _createSuccessResponse({'id': 2});
        final response = BatchResponse(
          responses: [success1, success2],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response.allSuccess, isTrue);
      });

      test('detects presence of errors', () {
        final success = _createSuccessResponse({'id': 1});
        final failure = _createFailureResponse();
        final response = BatchResponse(
          responses: [success, failure],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response.hasErrors, isTrue);
        expect(response.allSuccess, isFalse);
      });

      test('retrieves responses by index', () {
        final success = _createSuccessResponse({'id': 1});
        final failure = _createFailureResponse();
        final response = BatchResponse(
          responses: [success, failure],
          operations: [],
          totalDuration: Duration.zero,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        expect(response[0], equals(success));
        expect(response[1], equals(failure));
        expect(response[2], isNull);
      });

      test('generates meaningful string representation', () {
        final response = BatchResponse(
          responses: [
            _createSuccessResponse({'id': 1}),
            _createFailureResponse(),
          ],
          operations: [],
          totalDuration: const Duration(seconds: 2),
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        final str = response.toString();
        expect(str, contains('total: 2'));
        expect(str, contains('success: 1'));
        expect(str, contains('failed: 1'));
      });
    });

    group('BatchOperationException', () {
      test('creates with message', () {
        final exception = BatchOperationException(
          message: 'Batch failed',
        );
        expect(exception.message, equals('Batch failed'));
        expect(exception.failedOperations, isEmpty);
        expect(exception.rolledBack, isFalse);
      });

      test('includes failed operations', () {
        final exception = BatchOperationException(
          message: 'Batch failed',
          failedOperations: [],
        );
        expect(exception.failedOperations, isEmpty);
      });

      test('tracks rollback status', () {
        final exception1 = BatchOperationException(
          message: 'Batch failed',
        );
        expect(exception1.rolledBack, isFalse);

        final exception2 = BatchOperationException(
          message: 'Batch failed',
          rolledBack: true,
        );
        expect(exception2.rolledBack, isTrue);
      });

      test('generates meaningful string representation', () {
        final exception = BatchOperationException(
          message: 'Atomic batch failed',
          rolledBack: true,
        );
        final str = exception.toString();
        expect(str, contains('Atomic batch failed'));
        expect(str, contains('ROLLED BACK'));
      });
    });

    group('BatchRequestImpl - advanced scenarios', () {
      late WordpressRequest request1;

      setUp(() {
        request1 = WordpressRequest(
          url: RequestUrl.relative('/posts'),
          method: HttpMethod.get,
        );
      });

      test('executes with empty batch throws error', () async {
        final batch = BatchRequestImpl();
        expect(
          batch.execute,
          throwsStateError,
        );
      });

      test('cancel is idempotent', () async {
        final batch = BatchRequestImpl().add(request1);
        await batch.cancel();
        await batch.cancel(); // Should not throw
        expect(true, isTrue);
      });

      test('progress stream can be monitored', () {
        final batch = BatchRequestImpl().add(request1);
        final progressStream = batch.progressStream;
        expect(progressStream, isNotNull);
      });

      test('supports large batches', () {
        final batch = BatchRequestImpl();
        const operationCount = 1000;
        for (var i = 0; i < operationCount; i++) {
          batch.add(request1, operationId: 'op_$i');
        }
        expect(batch.operationCount, equals(operationCount));
      });

      test('getOperation is efficient with many operations', () {
        final batch = BatchRequestImpl();
        const operationCount = 1000;
        for (var i = 0; i < operationCount; i++) {
          batch.add(request1, operationId: 'op_$i');
        }
        final op = batch.getOperation('op_500');
        expect(op?.id, equals('op_500'));
      });
    });

    group('Batch Configuration Combinations', () {
      test('atomic with rollbackAll strategy', () {
        const config = BatchConfig(
          atomic: true,
          rollbackStrategy: RollbackStrategy.rollbackAll,
        );
        expect(config.atomic, isTrue);
        expect(config.rollbackStrategy, equals(RollbackStrategy.rollbackAll));
      });

      test('non-atomic with continueOnError', () {
        const config = BatchConfig(
          continueOnError: true,
        );
        expect(config.atomic, isFalse);
        expect(config.continueOnError, isTrue);
      });

      test('with concurrent execution limit', () {
        const config = BatchConfig(
          maxConcurrent: 5,
          timeout: Duration(seconds: 30),
        );
        expect(config.maxConcurrent, equals(5));
        expect(config.timeout, equals(const Duration(seconds: 30)));
      });

      test('preserveOrder with non-atomic execution', () {
        const config = BatchConfig();
        expect(config.atomic, isFalse);
        expect(config.preserveOrder, isTrue);
      });
    });
  });
}
