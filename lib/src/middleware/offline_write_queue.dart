import 'dart:async';
import 'dart:convert';

import '../library_exports.dart';

/// A write (POST, PUT, PATCH or DELETE) that could not reach the server and
/// is waiting to be replayed by [OfflineWriteQueue.flush].
///
/// Only the method, URL, query, body and `requireAuth` flag are kept. Headers
/// and credentials are deliberately not stored: a replay is authorized by the
/// client that flushes it.
final class QueuedWrite {
  const QueuedWrite({
    required this.id,
    required this.method,
    required this.url,
    required this.isAbsolute,
    required this.queuedAt,
    this.query,
    this.body,
    this.requireAuth = true,
  });

  /// Restores a write saved with [toJson].
  factory QueuedWrite.fromJson(Map<String, dynamic> json) {
    return QueuedWrite(
      id: json['id'] as String,
      method: json['method'] as String,
      url: json['url'] as String,
      isAbsolute: json['isAbsolute'] as bool? ?? false,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      query: (json['query'] as Map?)?.cast<String, dynamic>(),
      body: json['body'],
      requireAuth: json['requireAuth'] as bool? ?? true,
    );
  }

  /// Unique, increasing identifier.
  final String id;

  /// Lower-case HTTP method name (`post`, `put`, `patch`, `delete`).
  final String method;

  /// The request URL as it was given (relative to the client, or absolute).
  final String url;

  /// Whether [url] is absolute.
  final bool isAbsolute;

  /// When the write was queued.
  final DateTime queuedAt;

  /// Query parameters.
  final Map<String, dynamic>? query;

  /// JSON body.
  final dynamic body;

  /// Whether the replay must be authenticated.
  final bool requireAuth;

  /// A JSON encodable form, for stores that persist to disk.
  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'url': url,
        'isAbsolute': isAbsolute,
        'queuedAt': queuedAt.toIso8601String(),
        'query': query,
        'body': body,
        'requireAuth': requireAuth,
      };

  /// The request that replays this write.
  WordpressRequest toRequest() {
    return WordpressRequest(
      url: isAbsolute
          ? RequestUrl.absolute(Uri.parse(url))
          : RequestUrl.relative(url),
      method: HttpMethod.values.firstWhere((m) => m.name == method),
      queryParameters: query,
      body: body,
      requireAuth: requireAuth,
      extra: const {OfflineWriteQueue.replayKey: true},
    );
  }

  @override
  String toString() => '${method.toUpperCase()} $url';
}

/// Where an [OfflineWriteQueue] keeps its writes.
///
/// Implement this on top of `shared_preferences`, a file or a database to
/// survive app restarts (see [QueuedWrite.toJson]).
abstract interface class WriteQueueStore {
  /// Every queued write, oldest first.
  Future<List<QueuedWrite>> all();

  /// Appends [write].
  Future<void> add(QueuedWrite write);

  /// Removes the write with [id].
  Future<void> remove(String id);
}

/// A [WriteQueueStore] kept in memory (lost when the app exits).
final class MemoryWriteQueueStore implements WriteQueueStore {
  final List<QueuedWrite> _writes = [];

  @override
  Future<List<QueuedWrite>> all() async => List.unmodifiable(_writes);

  @override
  Future<void> add(QueuedWrite write) async => _writes.add(write);

  @override
  Future<void> remove(String id) async {
    _writes.removeWhere((w) => w.id == id);
  }
}

/// A write that the server answered with an error during [OfflineWriteQueue.flush].
final class RejectedWrite {
  const RejectedWrite(this.write, this.response);

  final QueuedWrite write;
  final WordpressRawResponse response;
}

/// The outcome of [OfflineWriteQueue.flush].
final class FlushResult {
  const FlushResult({
    required this.sent,
    required this.rejected,
    required this.remaining,
  });

  /// Writes the server accepted. They are removed from the queue.
  final List<QueuedWrite> sent;

  /// Writes the server refused for good (a 4xx such as `rest_forbidden`).
  /// They are removed from the queue; retrying cannot help.
  final List<RejectedWrite> rejected;

  /// Writes still queued: flushing stopped at the first one that could not be
  /// delivered (still offline, or a 5xx / 429 answer).
  final int remaining;

  /// True when nothing is left in the queue.
  bool get isDrained => remaining == 0;
}

/// Keeps writes that fail because the device is offline and replays them
/// later, in order.
///
/// A POST, PUT, PATCH or DELETE that fails with
/// [RequestErrorType.connectionFailed] is stored, and its failure response is
/// flagged (see `QueuedResponse.wasQueued`). Call [flush] when connectivity
/// is back (for example from a `connectivity_plus` listener):
///
/// ```dart
/// final queue = OfflineWriteQueue(store: MemoryWriteQueueStore());
/// final client = WordpressClient.forSite(
///   siteUrl: siteUrl,
///   bootstrapper: (b) => b.withMiddleware(queue).build(),
/// );
///
/// final response = await client.posts.create(CreatePostRequest(title: 'Hi'));
/// if (response.wasQueued) showSnack('Saved, will sync when online');
///
/// // later
/// final result = await queue.flush(client);
/// ```
///
/// Notes:
/// * Only JSON bodies are queued. Uploads (multipart, streams) are not.
/// * A timeout may mean the server did process the write, so replaying could
///   duplicate it. Timeouts are only queued with [queueOnTimeout].
/// * Reads are never queued, and a queued write is not re-queued while it is
///   being replayed.
final class OfflineWriteQueue extends IWordpressMiddleware {
  OfflineWriteQueue({
    required this.store,
    this.maxLength = 100,
    this.queueOnTimeout = false,
    this.methods = const {
      HttpMethod.post,
      HttpMethod.put,
      HttpMethod.patch,
      HttpMethod.delete,
    },
  });

  /// [WordpressRawResponse.extra] key set on a response whose request was
  /// queued; its value is the [QueuedWrite.id].
  static const String queuedKey = 'wp.queue.id';

  /// [WordpressRequest.extra] key marking a replayed request.
  static const String replayKey = 'wp.queue.replay';

  static const String _pendingKey = 'wp.queue.pending';

  /// Where writes are kept.
  final WriteQueueStore store;

  /// Writes beyond this many are not queued (their failure is returned as is).
  final int maxLength;

  /// Also queue writes that timed out. Off by default, see the class notes.
  final bool queueOnTimeout;

  /// Which methods are queued.
  final Set<HttpMethod> methods;

  final Map<String, QueuedWrite> _pending = {};
  int _sequence = 0;
  Future<FlushResult>? _flushing;

  /// Whether [response] is a failure whose request was queued for later.
  static bool wasQueuedResponse(WordpressRawResponse response) {
    return response.extra[queuedKey] != null;
  }

  @override
  String get name => 'OfflineWriteQueue';

  @override
  Future<void> onLoad() async {}

  @override
  Future<void> onUnload() async {}

  /// Number of writes waiting.
  Future<int> get length async => (await store.all()).length;

  /// The writes waiting, oldest first.
  Future<List<QueuedWrite>> get pending => store.all();

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    if (request.extra[replayKey] == true || !methods.contains(request.method)) {
      return request;
    }

    final write = _describe(request);
    if (write == null) {
      return request;
    }

    _pending[write.id] = write;

    return request.copyWith(
      extra: {...request.extra, _pendingKey: write.id},
    );
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    final id = response.extra[_pendingKey];
    if (id is! String) {
      return response;
    }

    final write = _pending.remove(id);
    final retryable = response.code ==
            -RequestErrorType.connectionFailed.index ||
        (queueOnTimeout && response.code == -RequestErrorType.timeout.index);

    if (write == null || !retryable) {
      return response;
    }

    if ((await store.all()).length >= maxLength) {
      return response;
    }

    await store.add(write);

    return response.copyWith(extra: {...response.extra, queuedKey: write.id});
  }

  /// Replays the queued writes, oldest first, through [client].
  ///
  /// Accepted writes are removed. A write the server refuses with a client
  /// error is removed and reported in [FlushResult.rejected]. Flushing stops
  /// at the first write that cannot be delivered (still offline, a 5xx, 408
  /// or 429) and leaves it and the rest queued, preserving order. Calling
  /// [flush] while one is running returns the running one.
  Future<FlushResult> flush(WordpressClient client) {
    return _flushing ??= _flush(client).whenComplete(() {
      _flushing = null;
    });
  }

  Future<FlushResult> _flush(WordpressClient client) async {
    final writes = await store.all();
    final sent = <QueuedWrite>[];
    final rejected = <RejectedWrite>[];

    for (final write in writes) {
      final response = await client.raw(write.toRequest());

      if (response.isSuccessful) {
        await store.remove(write.id);
        sent.add(write);
        continue;
      }

      final code = response.code;
      final clientError =
          code >= 400 && code < 500 && code != 408 && code != 429;
      final unsendable = code < 0 && !_isTransport(code);

      if (!clientError && !unsendable) {
        break;
      }

      await store.remove(write.id);
      rejected.add(RejectedWrite(write, response));
    }

    return FlushResult(
      sent: sent,
      rejected: rejected,
      remaining: (await store.all()).length,
    );
  }

  static bool _isTransport(int code) {
    return code == -RequestErrorType.connectionFailed.index ||
        code == -RequestErrorType.timeout.index;
  }

  QueuedWrite? _describe(WordpressRequest request) {
    final body = request.body;
    final query = <String, dynamic>{
      for (final entry in (request.queryParameters ?? const {}).entries)
        if (entry.value != null) entry.key: entry.value,
    };

    final write = QueuedWrite(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
      method: request.method.name,
      url: request.url.toString(),
      isAbsolute: request.url.isAbsolute,
      queuedAt: DateTime.now(),
      query: query.isEmpty ? null : query,
      body: body,
      requireAuth: request.requireAuth,
    );

    // Streams, FormData and other non JSON payloads cannot be replayed.
    try {
      jsonEncode(write.toJson());
    } catch (_) {
      return null;
    }

    return write;
  }
}

/// Convenience for the result of a request made while [OfflineWriteQueue] is
/// installed.
extension QueuedResponse on WordpressResponse<dynamic> {
  /// True when the request failed because the device was offline and the
  /// write was queued to be replayed by [OfflineWriteQueue.flush].
  bool get wasQueued => extra?[OfflineWriteQueue.queuedKey] != null;
}
