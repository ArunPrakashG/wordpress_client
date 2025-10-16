import 'package:meta/meta.dart';

/// Tracks cache performance metrics and statistics.
@immutable
class CacheStatistics {
  const CacheStatistics({
    required this.hits,
    required this.misses,
    required this.evictions,
    required this.invalidations,
    required this.currentEntryCount,
    required this.currentSizeBytes,
    required this.peakEntryCount,
    required this.peakSizeBytes,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.evictionReasons = const {},
  });

  /// Total number of cache hits
  final int hits;

  /// Total number of cache misses
  final int misses;

  /// Total number of cache evictions
  final int evictions;

  /// Total number of cache invalidations
  final int invalidations;

  /// Current number of entries in cache
  final int currentEntryCount;

  /// Current cache size in bytes
  final int currentSizeBytes;

  /// Peak number of entries reached
  final int peakEntryCount;

  /// Peak cache size in bytes
  final int peakSizeBytes;

  /// Timestamp of cache creation
  final DateTime createdAt;

  /// Last time statistics were updated
  final DateTime lastUpdatedAt;

  /// Breakdown of evictions by reason
  final Map<String, int> evictionReasons;

  /// Cache hit ratio (0.0 to 1.0)
  double get hitRatio {
    final total = hits + misses;
    if (total == 0) return 0;
    return hits / total;
  }

  /// Cache miss ratio (0.0 to 1.0)
  double get missRatio => 1.0 - hitRatio;

  /// Total cache requests
  int get totalRequests => hits + misses;

  /// Time since cache was created
  Duration get uptime => DateTime.now().difference(createdAt);

  /// Average hits per minute
  double get hitsPerMinute {
    final minutes = uptime.inSeconds / 60;
    if (minutes < 1) return 0;
    return hits / minutes;
  }

  /// Create initial statistics
  static CacheStatistics initial() {
    final now = DateTime.now();
    return CacheStatistics(
      hits: 0,
      misses: 0,
      evictions: 0,
      invalidations: 0,
      currentEntryCount: 0,
      currentSizeBytes: 0,
      peakEntryCount: 0,
      peakSizeBytes: 0,
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  /// Create a copy with updated fields
  CacheStatistics copyWith({
    int? hits,
    int? misses,
    int? evictions,
    int? invalidations,
    int? currentEntryCount,
    int? currentSizeBytes,
    int? peakEntryCount,
    int? peakSizeBytes,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    Map<String, int>? evictionReasons,
  }) {
    return CacheStatistics(
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      evictions: evictions ?? this.evictions,
      invalidations: invalidations ?? this.invalidations,
      currentEntryCount: currentEntryCount ?? this.currentEntryCount,
      currentSizeBytes: currentSizeBytes ?? this.currentSizeBytes,
      peakEntryCount: peakEntryCount ?? this.peakEntryCount,
      peakSizeBytes: peakSizeBytes ?? this.peakSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      evictionReasons: evictionReasons ?? this.evictionReasons,
    );
  }

  /// Record a cache hit
  CacheStatistics recordHit({int entryCount = 0, int sizeBytes = 0}) {
    return copyWith(
      hits: hits + 1,
      currentEntryCount: entryCount > 0 ? entryCount : currentEntryCount,
      currentSizeBytes: sizeBytes > 0 ? sizeBytes : currentSizeBytes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Record a cache miss
  CacheStatistics recordMiss({int entryCount = 0, int sizeBytes = 0}) {
    return copyWith(
      misses: misses + 1,
      currentEntryCount: entryCount > 0 ? entryCount : currentEntryCount,
      currentSizeBytes: sizeBytes > 0 ? sizeBytes : currentSizeBytes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Record an eviction
  CacheStatistics recordEviction(
    String reason, {
    int entryCount = 0,
    int sizeBytes = 0,
  }) {
    final newReasons = Map<String, int>.from(evictionReasons);
    newReasons[reason] = (newReasons[reason] ?? 0) + 1;

    return copyWith(
      evictions: evictions + 1,
      currentEntryCount: entryCount > 0 ? entryCount : currentEntryCount,
      currentSizeBytes: sizeBytes > 0 ? sizeBytes : currentSizeBytes,
      evictionReasons: newReasons,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Record invalidation
  CacheStatistics recordInvalidation({int entryCount = 0, int sizeBytes = 0}) {
    return copyWith(
      invalidations: invalidations + 1,
      currentEntryCount: entryCount > 0 ? entryCount : currentEntryCount,
      currentSizeBytes: sizeBytes > 0 ? sizeBytes : currentSizeBytes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Update peak values if current exceeds peaks
  CacheStatistics updatePeaks() {
    return copyWith(
      peakEntryCount: currentEntryCount > peakEntryCount
          ? currentEntryCount
          : peakEntryCount,
      peakSizeBytes:
          currentSizeBytes > peakSizeBytes ? currentSizeBytes : peakSizeBytes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => '''CacheStatistics(
  hitRatio: ${(hitRatio * 100).toStringAsFixed(2)}%,
  requests: $totalRequests (hits: $hits, misses: $misses),
  evictions: $evictions, invalidations: $invalidations,
  current: $currentEntryCount entries, ${(currentSizeBytes / 1024).toStringAsFixed(2)} KB,
  peak: $peakEntryCount entries, ${(peakSizeBytes / 1024).toStringAsFixed(2)} KB,
  uptime: ${uptime.inSeconds}s,
)''';
}
