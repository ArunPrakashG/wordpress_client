import 'dart:async';

import 'package:dio/dio.dart';

import '../library_exports.dart';

/// Represents a custom operation for interacting with WordPress APIs.
/// This mixin is used to create custom operations that can execute requests
/// and handle responses.
base mixin CustomOperation<T, R extends IRequest> on IRequestInterface {
  /// Decodes the JSON response into the desired type [T].
  /// Implement this method to define how the API response should be parsed.
  T decode(dynamic json);

  /// Executes the given [request] and returns a typed response.
  ///
  /// This method performs the following steps:
  /// 1. Builds the WordPress request using the provided [request] object.
  /// 2. Executes the request using the [executor].
  /// 3. Decodes the response using the [decode] method.
  ///
  /// Returns a [WordpressResponse] containing the decoded data of type [T].
  Future<WordpressResponse<T>> request(R request) async {
    final wpRequest = await request.build(baseUrl);

    final response = await executor.execute(wpRequest);

    return response.asResponse<T>(decoder: decode);
  }

  /// Returns the raw response for the given [request] without decoding.
  ///
  /// This method is useful when you need access to the unprocessed API response.
  /// It performs the following steps:
  /// 1. Builds the WordPress request using the provided [request] object.
  /// 2. Executes the request using the [executor] in raw mode.
  ///
  /// Returns a [WordpressRawResponse] containing the unprocessed API response.
  Future<WordpressRawResponse> raw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }

  /// Starts a polling stream that periodically executes the same custom request and emits updates.
  ///
  /// See [RetrieveOperation.retrieveStream] for semantics. This variant uses [decode]
  /// to map the successful raw payloads into [T].
  Stream<WordpressResponse<T>> requestStream(
    R request, {
    Duration interval = const Duration(minutes: 1),
    bool emitOnStart = true,
    bool distinctData = true,
    bool emitFailures = true,
    bool dedupeFailures = true,
    bool Function(T previous, T current)? equals,
    CancelToken? cancelToken,
    Stream<void>? refetchTrigger,
  }) {
    final controller = StreamController<WordpressResponse<T>>.broadcast();
    final token = cancelToken ?? CancelToken();

    T? lastSuccess;
    int? lastFailureCode;
    String? lastFailureMessage;
    bool inFlight = false;
    bool scheduleImmediateAfterFlight = false;

    Timer? timer;
    StreamSubscription<void>? triggerSub;

    Future<void> emitIfNeeded(WordpressResponse<T> res) async {
      if (res is WordpressSuccessResponse<T>) {
        final data = res.data;
        var shouldEmit = true;
        if (distinctData && lastSuccess != null) {
          final equal = equals != null ? equals(lastSuccess as T, data) : lastSuccess == data;
          shouldEmit = !equal;
        }
        if (shouldEmit) {
          lastSuccess = data;
          lastFailureCode = null;
          lastFailureMessage = null;
          if (!controller.isClosed) controller.add(res);
        }
      } else if (res is WordpressFailureResponse<T>) {
        if (emitFailures) {
          final sameFailure = dedupeFailures &&
              lastFailureCode == res.code &&
              lastFailureMessage == res.message;
          if (!sameFailure) {
            lastFailureCode = res.code;
            lastFailureMessage = res.message;
            if (!controller.isClosed) controller.add(res);
          }
        }
      }
    }

    Future<void> runOnce() async {
      if (token.isCancelled) return;
      inFlight = true;
      try {
        final built = await request.build(baseUrl);
        final withCancel = built.copyWith(cancelToken: token);
        final rawRes = await executor.execute(withCancel);
        final res = rawRes.asResponse<T>(decoder: decode);
        await emitIfNeeded(res);
      } catch (_) {
      } finally {
        inFlight = false;
        if (scheduleImmediateAfterFlight && !token.isCancelled) {
          scheduleImmediateAfterFlight = false;
          // ignore: discarded_futures
          unawaited(runOnce());
        }
      }
    }

    Future<void> teardown() async {
      try {
        timer?.cancel();
        await triggerSub?.cancel();
      } finally {
        if (!token.isCancelled) {
          token.cancel('Polling stream cancelled');
        }
      }
    }

    void scheduleRun() {
      if (token.isCancelled) {
        // ignore: discarded_futures
        unawaited(teardown());
        if (!controller.isClosed) {
          // ignore: discarded_futures
          unawaited(controller.close());
        }
        return;
      }
      if (!inFlight) {
        // ignore: discarded_futures
        unawaited(runOnce());
      } else {
        scheduleImmediateAfterFlight = true;
      }
    }

    controller.onListen = () {
      // Ensure immediate completion when the external token is cancelled
      // ignore: discarded_futures
      unawaited(token.whenCancel.then((_) async {
        await teardown();
        if (!controller.isClosed) {
          await controller.close();
        }
      }));

      if (emitOnStart) scheduleRun();
      timer = Timer.periodic(interval, (_) => scheduleRun());
      if (refetchTrigger != null) {
        triggerSub = refetchTrigger.listen((_) => scheduleRun());
      }
    };

    controller.onCancel = () async {
      await teardown();
      await controller.close();
    };

    return controller.stream;
  }
}
