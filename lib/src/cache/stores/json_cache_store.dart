import 'dart:async';
import 'dart:convert';

import '../../responses/wordpress_raw_response.dart';
import '../../utilities/json_persistence.dart';
import '../cache_entry.dart';
import '../selective_cache.dart';

/// A cache for `CacheMiddleware` saved as one JSON document through two
/// callbacks, so cached responses survive app restarts on any text storage:
/// `shared_preferences`, a file, browser `localStorage`.
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final cache = JsonCacheStore(
///   read: () async => prefs.getString('wp_cache'),
///   write: (json) => prefs.setString('wp_cache', json),
/// );
/// final client = WordpressClient.forSite(
///   siteUrl: siteUrl,
///   bootstrapper: (b) => b.withMiddleware(CacheMiddleware(cache: cache)).build(),
/// );
/// ```
///
/// Request headers are not saved, so credentials never reach the storage
/// (cache keys only hold a one-way digest of them). Responses whose body is
/// not JSON are kept in memory only. Beyond [maxEntries] the least recently
/// stored entries are dropped. The document is read once, on first use, and
/// written after every change; `package:wordpress_client/io.dart` has a
/// file-backed `FileCacheStore`.
final class JsonCacheStore implements ISelectiveCache<WordpressRawResponse> {
  JsonCacheStore({
    required PersistRead read,
    required PersistWrite write,
    this.maxEntries = 200,
  })  : assert(maxEntries > 0, 'maxEntries must be positive'),
        _persistence = JsonPersistence(read: read, write: write);

  /// The most entries kept. Older ones are dropped first.
  final int maxEntries;

  final JsonPersistence _persistence;
  Future<Map<String, CacheEntry<WordpressRawResponse>>>? _entries;

  Future<Map<String, CacheEntry<WordpressRawResponse>>> _load() {
    return _entries ??= _persistence.load().then((document) {
      final entries = <String, CacheEntry<WordpressRawResponse>>{};
      if (document is! Map) {
        return entries;
      }

      for (final MapEntry(:key, :value) in document.entries) {
        try {
          final json = (value as Map).cast<String, dynamic>();
          final expires = json['expiresAt'] as int?;
          final entry = CacheEntry(
            WordpressRawResponse.fromJson(
              (json['response'] as Map).cast<String, dynamic>(),
            ),
            expires == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(expires),
          );
          if (!entry.isExpired) {
            entries[key as String] = entry;
          }
        } catch (_) {
          // Skip an entry that was saved by an incompatible version.
        }
      }

      return entries;
    });
  }

  Future<void> _save(Map<String, CacheEntry<WordpressRawResponse>> entries) {
    final document = <String, Object?>{};
    for (final MapEntry(:key, :value) in entries.entries) {
      final json = {
        'expiresAt': value.expiryTime?.millisecondsSinceEpoch,
        'response': value.value.toJson(),
      };

      try {
        jsonEncode(json);
        document[key] = json;
      } catch (_) {
        // Not JSON (bytes, a stream): served from memory, never saved.
      }
    }

    return _persistence.save(document);
  }

  @override
  Future<void> set(
    String key,
    WordpressRawResponse value, {
    Duration? expiry,
  }) async {
    final entries = await _load();
    entries
      ..remove(key)
      ..[key] = CacheEntry(
        value,
        expiry == null ? null : DateTime.now().add(expiry),
      );

    while (entries.length > maxEntries) {
      entries.remove(entries.keys.first);
    }

    await _save(entries);
  }

  @override
  Future<WordpressRawResponse?> get(String key) async {
    final entries = await _load();
    final entry = entries[key];
    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      entries.remove(key);
      await _save(entries);
      return null;
    }

    return entry.value;
  }

  @override
  Future<void> remove(String key) async {
    final entries = await _load();
    if (entries.remove(key) != null) {
      await _save(entries);
    }
  }

  @override
  Future<void> removeWhere(bool Function(String key) test) async {
    final entries = await _load();
    final before = entries.length;
    entries.removeWhere((key, _) => test(key));
    if (entries.length != before) {
      await _save(entries);
    }
  }

  @override
  Future<void> clear() async {
    final entries = await _load();
    entries.clear();
    await _save(entries);
  }
}
