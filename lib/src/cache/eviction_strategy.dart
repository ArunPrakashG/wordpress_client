import 'advanced_cache_config.dart';
import 'advanced_cache_entry.dart';

/// Interface for cache eviction strategies.
abstract interface class IEvictionStrategy {
  /// Selects entry/entries to evict from the given cache entries.
  /// Returns the key of the entry to evict.
  String selectForEviction(
    Map<String, AdvancedCacheEntry> entries,
    EvictionStrategy strategy,
  );

  /// Get strategy name for logging
  String get name;
}

/// Least Recently Used eviction strategy.
/// Evicts the entry that was accessed least recently.
class LRUEvictionStrategy implements IEvictionStrategy {
  @override
  String selectForEviction(
    Map<String, AdvancedCacheEntry> entries,
    EvictionStrategy strategy,
  ) {
    if (entries.isEmpty) throw StateError('No entries to evict');

    // Find entry with oldest last access time
    String? keyToEvict;
    DateTime? oldestAccess;

    for (final entry in entries.values) {
      final accessTime = entry.lastAccessedAt ?? entry.createdAt;

      if (oldestAccess == null || accessTime.isBefore(oldestAccess)) {
        oldestAccess = accessTime;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict!;
  }

  @override
  String get name => 'LRU (Least Recently Used)';
}

/// Least Frequently Used eviction strategy.
/// Evicts the entry with the lowest access count.
class LFUEvictionStrategy implements IEvictionStrategy {
  @override
  String selectForEviction(
    Map<String, AdvancedCacheEntry> entries,
    EvictionStrategy strategy,
  ) {
    if (entries.isEmpty) throw StateError('No entries to evict');

    // Find entry with lowest access count
    String? keyToEvict;
    int? lowestCount;

    for (final entry in entries.values) {
      if (lowestCount == null || entry.accessCount < lowestCount) {
        lowestCount = entry.accessCount;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict!;
  }

  @override
  String get name => 'LFU (Least Frequently Used)';
}

/// First In First Out eviction strategy.
/// Evicts the oldest entry (by creation time).
class FIFOEvictionStrategy implements IEvictionStrategy {
  @override
  String selectForEviction(
    Map<String, AdvancedCacheEntry> entries,
    EvictionStrategy strategy,
  ) {
    if (entries.isEmpty) throw StateError('No entries to evict');

    // Find entry with oldest creation time
    String? keyToEvict;
    DateTime? oldestCreation;

    for (final entry in entries.values) {
      if (oldestCreation == null || entry.createdAt.isBefore(oldestCreation)) {
        oldestCreation = entry.createdAt;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict!;
  }

  @override
  String get name => 'FIFO (First In First Out)';
}

/// Largest First eviction strategy.
/// Evicts the largest entry by size first (good for size-constrained caches).
class LargestFirstEvictionStrategy implements IEvictionStrategy {
  @override
  String selectForEviction(
    Map<String, AdvancedCacheEntry> entries,
    EvictionStrategy strategy,
  ) {
    if (entries.isEmpty) throw StateError('No entries to evict');

    // Find largest entry
    String? keyToEvict;
    int? largestSize;

    for (final entry in entries.values) {
      if (largestSize == null || entry.sizeBytes > largestSize) {
        largestSize = entry.sizeBytes;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict!;
  }

  @override
  String get name => 'Largest First';
}

/// Factory for creating eviction strategies.
class EvictionStrategyFactory {
  static IEvictionStrategy create(EvictionStrategy strategy) {
    return switch (strategy) {
      EvictionStrategy.lru => LRUEvictionStrategy(),
      EvictionStrategy.lfu => LFUEvictionStrategy(),
      EvictionStrategy.fifo => FIFOEvictionStrategy(),
      EvictionStrategy.largestFirst => LargestFirstEvictionStrategy(),
    };
  }
}
