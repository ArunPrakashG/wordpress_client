import 'dart:async';

import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

/// Represents the retrieve operation for WordPress API requests.
///
/// This mixin provides methods to retrieve data from a WordPress site
/// using the WordPress REST API.
base mixin RetrieveOperation<T, R extends IRequest> on IRequestInterface {
  /// Retrieves data from the WordPress API and returns a typed response.
  ///
  /// [request] is the request object containing the necessary parameters.
  ///
  /// Returns a [Future] that resolves to a [WordpressResponse] containing
  /// the retrieved data of type [T].
  Future<WordpressResponse<T>> retrieve(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.retrive<T>(wpRequest);
  }

  /// Retrieves raw data from the WordPress API.
  ///
  /// [request] is the request object containing the necessary parameters.
  ///
  /// Returns a [Future] that resolves to a [WordpressRawResponse] containing
  /// the raw response data from the API.
  Future<WordpressRawResponse> retrieveRaw(R request) async {
    final wpRequest = await request.build(baseUrl);

    return executor.raw(wpRequest);
  }

  /// Starts a polling stream that periodically retrieves the same resource and emits updates.
  ///
  /// This is useful to keep UI or data layers (for example, Riverpod's StreamProvider)
  /// in sync with a single remote resource. List endpoints are not recommended for polling
  /// because of pagination semantics; prefer specific "retrieve" endpoints or resources
  /// that represent a single entity (e.g., settings, a post by id, current user, etc.).
  ///
  /// Parameters:
  /// - [request]: The request to build each poll cycle.
  /// - [interval]: Polling interval; defaults to 1 minute.
  /// - [emitOnStart]: If true, fetch and emit immediately before waiting for [interval].
  /// - [distinctData]: If true, only emit successful responses when the parsed data changes
  ///   compared to the previous successful emission. Equality is determined by [equals] if
  ///   provided, otherwise by the `==` operator of [T]. Many response models in this library
  ///   implement structural equality.
  /// - [emitFailures]: If true, failure responses are emitted to the stream; otherwise they're
  ///   ignored (but polling continues).
  /// - [dedupeFailures]: If true, identical consecutive failure responses (same code and message)
  ///   are not emitted repeatedly.
  /// - [equals]: Optional custom comparator for [T] to determine if two payloads are equal.
  ///
  /// Cancellation: Cancelling the returned stream subscription stops polling and attempts to
  /// cancel any in-flight request.
  Stream<WordpressResponse<T>> retrieveStream(
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
    // Controller-based implementation to support periodic polling and on-demand refetching
    final controller = StreamController<WordpressResponse<T>>.broadcast();

    // External token or our own
    final token = cancelToken ?? CancelToken();

    // State for dedupe and flow control
    T? lastSuccess;
    int? lastFailureCode;
    String? lastFailureMessage;
  var inFlight = false;
  var scheduleImmediateAfterFlight = false;

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
        final res = await executor.retrive<T>(withCancel);
        await emitIfNeeded(res);
      } catch (_) {
        // Errors during run are surfaced via failure responses by executor; swallow here.
      } finally {
        inFlight = false;
        // If something requested an immediate refetch while in flight, do it now once.
        if (scheduleImmediateAfterFlight && !token.isCancelled) {
          scheduleImmediateAfterFlight = false;
          // fire and forget; controller will get new emission if needed
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
        // If externally cancelled, stop periodic work and close the stream
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
      // If the token is cancelled externally, tear down and close immediately
      // so listeners receive onDone without waiting for the next tick.
      // ignore: discarded_futures
      unawaited(token.whenCancel.then((_) async {
        await teardown();
        if (!controller.isClosed) {
          await controller.close();
        }
      },),);

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
