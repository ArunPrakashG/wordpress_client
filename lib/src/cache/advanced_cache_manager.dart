import 'dart:async';

import 'advanced_cache_config.dart';
import 'advanced_cache_entry.dart';
import 'cache_invalidation.dart';
import 'cache_manager_base.dart';
import 'cache_statistics.dart';
import 'eviction_strategy.dart';

/// Advanced cache manager with multi-level caching, intelligent eviction,
/// tag-based invalidation, and comprehensive statistics.
class AdvancedCacheManager<T> implements ICacheManager<T> {
  AdvancedCacheManager(this.config)
      : _evictionStrategy =
            EvictionStrategyFactory.create(config.evictionStrategy) {
    _statistics = CacheStatistics.initial();
  }
  final AdvancedCacheConfig config;
  final Map<String, AdvancedCacheEntry<T>> _cache = {};
  final IEvictionStrategy _evictionStrategy;

  /// Maps tags to cache keys for efficient tag-based invalidation
  final Map<String, Set<String>> _tagIndex = {};

  /// Statistics tracking
  late CacheStatistics _statistics;

  /// Lock for thread-safe operations
  final _lock = AsyncLock();

  /// Get current statistics
  CacheStatistics get statistics => _statistics;

  /// Get number of entries in cache
  int get length => _cache.length;

  /// Get current cache size in bytes
  int get sizeBytes => _cache.values.fold(0, (sum, e) => sum + e.sizeBytes);

  /// Get hit ratio
  double get hitRatio => _statistics.hitRatio;

  @override
  Future<void> set(String key, T value, {Duration? expiry}) async {
    await _lock.acquire();
    try {
      final ttl = expiry ?? config.defaultTtl;
      final expiresAt = ttl.inSeconds > 0 ? DateTime.now().add(ttl) : null;

      final sizeBytes = _estimateSize(value);

      // Check if we need to evict before adding
      if (_shouldEvict()) {
        await _evictEntry();
      }

      final entry = AdvancedCacheEntry<T>(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        sizeBytes: sizeBytes,
      );

      _cache[key] = entry;

      if (config.enableStatistics) {
        _updateStatistics();
      }
    } finally {
      _lock.release();
    }
  }

  /// Set cache entry with tags for group invalidation
  Future<void> setWithTags(
    String key,
    T value,
    Set<String> tags, {
    Duration? expiry,
    int priority = 5,
  }) async {
    await _lock.acquire();
    try {
      final ttl = expiry ?? config.defaultTtl;
      final expiresAt = ttl.inSeconds > 0 ? DateTime.now().add(ttl) : null;

      final sizeBytes = _estimateSize(value);

      if (_shouldEvict()) {
        await _evictEntry();
      }

      final entry = AdvancedCacheEntry<T>(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        sizeBytes: sizeBytes,
        tags: tags,
        priority: priority,
      );

      // Remove old tags if entry exists
      if (_cache.containsKey(key)) {
        final oldTags = _cache[key]!.tags;
        for (final tag in oldTags) {
          _tagIndex[tag]?.remove(key);
        }
      }

      // Add new tags
      _cache[key] = entry;
      for (final tag in tags) {
        _tagIndex.putIfAbsent(tag, () => {}).add(key);
      }

      if (config.enableStatistics) {
        _updateStatistics();
      }
    } finally {
      _lock.release();
    }
  }

  @override
  Future<T?> get(String key) async {
    await _lock.acquire();
    try {
      final entry = _cache[key];

      // Check expiry
      if (entry != null && entry.isExpired) {
        _cache.remove(key);
        if (config.enableStatistics) {
          _statistics = _statistics.recordMiss(
            entryCount: _cache.length,
            sizeBytes: sizeBytes,
          );
        }
        return null;
      }

      if (entry != null) {
        // Update access tracking and return
        final accessedEntry = entry.withAccess();
        _cache[key] = accessedEntry;

        if (config.enableStatistics) {
          _statistics = _statistics.recordHit(
            entryCount: _cache.length,
            sizeBytes: sizeBytes,
          );
        }

        return entry.value;
      }

      // Miss
      if (config.enableStatistics) {
        _statistics = _statistics.recordMiss(
          entryCount: _cache.length,
          sizeBytes: sizeBytes,
        );
      }

      return null;
    } finally {
      _lock.release();
    }
  }

  /// Get entry without updating access stats (useful for introspection)
  Future<AdvancedCacheEntry<T>?> getEntry(String key) async {
    await _lock.acquire();
    try {
      final entry = _cache[key];
      if (entry != null && entry.isExpired) {
        _cache.remove(key);
        return null;
      }
      return entry;
    } finally {
      _lock.release();
    }
  }

  @override
  Future<void> remove(String key) async {
    await _lock.acquire();
    try {
      final entry = _cache.remove(key);
      if (entry != null) {
        // Remove from tag index
        for (final tag in entry.tags) {
          _tagIndex[tag]?.remove(key);
          if (_tagIndex[tag]?.isEmpty ?? false) {
            _tagIndex.remove(tag);
          }
        }

        if (config.enableStatistics) {
          _statistics = _statistics.copyWith(
            currentEntryCount: _cache.length,
            currentSizeBytes: sizeBytes,
            lastUpdatedAt: DateTime.now(),
          );
        }
      }
    } finally {
      _lock.release();
    }
  }

  /// Invalidate cache entries using a matcher
  Future<InvalidationResult> invalidate(IInvalidationMatcher matcher) async {
    await _lock.acquire();
    try {
      final invalidatedKeys = <String>[];
      final keysToRemove = <String>[];

      for (final entry in _cache.values) {
        if (_matchesInvalidation(matcher, entry)) {
          invalidatedKeys.add(entry.key);
          keysToRemove.add(entry.key);
        }
      }

      // Remove matched entries
      for (final key in keysToRemove) {
        await _removeAndCleanup(key);
      }

      if (config.enableStatistics) {
        _statistics = _statistics.recordInvalidation(
          entryCount: _cache.length,
          sizeBytes: sizeBytes,
        );
      }

      return InvalidationResult(
        count: invalidatedKeys.length,
        invalidatedKeys: invalidatedKeys,
        reason: matcher.description,
        timestamp: DateTime.now(),
      );
    } finally {
      _lock.release();
    }
  }

  /// Invalidate by exact key
  Future<void> invalidateKey(String key) async {
    await invalidate(InvalidationMatcher.exact(key));
  }

  /// Invalidate by tag
  Future<InvalidationResult> invalidateTag(String tag) async {
    await _lock.acquire();
    try {
      final keysToRemove = _tagIndex[tag]?.toList() ?? [];
      final invalidatedKeys = <String>[];

      for (final key in keysToRemove) {
        invalidatedKeys.add(key);
        await _removeAndCleanup(key);
      }

      if (config.enableStatistics) {
        _statistics = _statistics.recordInvalidation(
          entryCount: _cache.length,
          sizeBytes: sizeBytes,
        );
      }

      return InvalidationResult(
        count: invalidatedKeys.length,
        invalidatedKeys: invalidatedKeys,
        reason: 'tag: $tag',
        timestamp: DateTime.now(),
      );
    } finally {
      _lock.release();
    }
  }

  /// Invalidate by pattern (glob-like)
  Future<InvalidationResult> invalidatePattern(String pattern) async {
    return invalidate(InvalidationMatcher.pattern(pattern));
  }

  /// Invalidate WordPress paths (e.g., /posts/*)
  Future<InvalidationResult> invalidateWordpressPath(String path) async {
    return invalidate(InvalidationMatcher.wordpressPath(path));
  }

  @override
  Future<void> clear() async {
    await _lock.acquire();
    try {
      _cache.clear();
      _tagIndex.clear();
      if (config.enableStatistics) {
        _statistics = _statistics.recordInvalidation();
      }
    } finally {
      _lock.release();
    }
  }

  /// Get all keys currently in cache
  Future<List<String>> getAllKeys() async {
    await _lock.acquire();
    try {
      return _cache.keys.toList();
    } finally {
      _lock.release();
    }
  }

  /// Get all tags currently in use
  Future<List<String>> getAllTags() async {
    await _lock.acquire();
    try {
      return _tagIndex.keys.toList();
    } finally {
      _lock.release();
    }
  }

  /// Get all entries (for debugging/inspection)
  Future<List<AdvancedCacheEntry<T>>> getAllEntries() async {
    await _lock.acquire();
    try {
      return _cache.values.toList();
    } finally {
      _lock.release();
    }
  }

  /// Check if key exists in cache
  Future<bool> containsKey(String key) async {
    await _lock.acquire();
    try {
      final entry = _cache[key];
      if (entry != null && entry.isExpired) {
        _cache.remove(key);
        return false;
      }
      return entry != null;
    } finally {
      _lock.release();
    }
  }

  // Private helpers

  bool _shouldEvict() {
    if (_cache.length >= config.maxMemoryEntries) return true;
    if (config.maxMemorySizeBytes != null &&
        sizeBytes >= config.maxMemorySizeBytes!) {
      return true;
    }
    return false;
  }

  Future<void> _evictEntry() async {
    if (_cache.isEmpty) return;

    final keyToEvict =
        _evictionStrategy.selectForEviction(_cache, config.evictionStrategy);
    await _removeAndCleanup(keyToEvict);

    if (config.enableStatistics) {
      _statistics = _statistics.recordEviction(
        _evictionStrategy.name,
        entryCount: _cache.length,
        sizeBytes: sizeBytes,
      );
    }
  }

  Future<void> _removeAndCleanup(String key) async {
    final entry = _cache.remove(key);
    if (entry != null) {
      // Remove from tag index
      for (final tag in entry.tags) {
        _tagIndex[tag]?.remove(key);
        if (_tagIndex[tag]?.isEmpty ?? false) {
          _tagIndex.remove(tag);
        }
      }
    }
  }

  bool _matchesInvalidation(
      IInvalidationMatcher matcher, AdvancedCacheEntry<T> entry) {
    if (matcher is TagMatcher) {
      return matcher.matchesTags(entry.tags);
    }
    return matcher.matches(entry.key);
  }

  void _updateStatistics() {
    _statistics = _statistics
        .copyWith(
          currentEntryCount: _cache.length,
          currentSizeBytes: sizeBytes,
        )
        .updatePeaks();
  }

  int _estimateSize(T value) {
    // Rough estimation - can be overridden
    return value.toString().length;
  }
}

/// Simple async lock for thread-safe operations
class AsyncLock {
  bool _isLocked = false;
  final _waiters = <Completer<void>>[];

  Future<void> acquire() async {
    if (!_isLocked) {
      _isLocked = true;
      return;
    }

    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      _isLocked = false;
    }
  }
}
