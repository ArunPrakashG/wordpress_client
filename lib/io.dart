/// File-backed stores for apps that run on the Dart VM or Flutter on mobile
/// and desktop (anything with `dart:io`). Not available on the web, where
/// [JsonCacheStore] and [JsonWriteQueueStore] work over `localStorage` or
/// `shared_preferences` instead.
///
/// ```dart
/// import 'package:wordpress_client/io.dart';
/// import 'package:wordpress_client/wordpress_client.dart';
///
/// final dir = (await getApplicationSupportDirectory()).path;
/// final queue = OfflineWriteQueue(store: FileWriteQueueStore('$dir/wp_queue.json'));
/// final cache = CacheMiddleware(cache: FileCacheStore('$dir/wp_cache.json'));
/// ```
library wordpress_client.io;

import 'dart:io';

import 'wordpress_client.dart';

/// Reads [path], or null when the file does not exist yet.
Future<String?> _read(String path) async {
  final file = File(path);

  return file.existsSync() ? file.readAsString() : null;
}

/// Writes [contents] to a sibling temporary file and renames it over [path],
/// so a crash mid-write never leaves a truncated file behind.
Future<void> _write(String path, String contents) async {
  final file = File(path);
  await file.parent.create(recursive: true);

  final temp = File('$path.tmp');
  await temp.writeAsString(contents, flush: true);
  await temp.rename(path);
}

/// A [JsonWriteQueueStore] kept in the file at [path] (created on first
/// write, with any missing parent directories).
final class FileWriteQueueStore implements WriteQueueStore {
  FileWriteQueueStore(this.path)
      : _store = JsonWriteQueueStore(
          read: () => _read(path),
          write: (contents) => _write(path, contents),
        );

  /// The file holding the queue.
  final String path;

  final JsonWriteQueueStore _store;

  @override
  Future<List<QueuedWrite>> all() => _store.all();

  @override
  Future<void> add(QueuedWrite write) => _store.add(write);

  @override
  Future<void> remove(String id) => _store.remove(id);
}

/// A [JsonCacheStore] kept in the file at [path] (created on first write,
/// with any missing parent directories).
final class FileCacheStore implements ISelectiveCache<WordpressRawResponse> {
  FileCacheStore(this.path, {int maxEntries = 200})
      : _store = JsonCacheStore(
          read: () => _read(path),
          write: (contents) => _write(path, contents),
          maxEntries: maxEntries,
        );

  /// The file holding the cache.
  final String path;

  final JsonCacheStore _store;

  @override
  Future<void> set(
    String key,
    WordpressRawResponse value, {
    Duration? expiry,
  }) =>
      _store.set(key, value, expiry: expiry);

  @override
  Future<WordpressRawResponse?> get(String key) => _store.get(key);

  @override
  Future<void> remove(String key) => _store.remove(key);

  @override
  Future<void> removeWhere(bool Function(String key) test) =>
      _store.removeWhere(test);

  @override
  Future<void> clear() => _store.clear();
}
