/// Configuration for advanced cache behavior and policies.
enum EvictionStrategy {
  /// Least Recently Used - evicts least recently accessed entries
  lru,

  /// Least Frequently Used - evicts least frequently accessed entries
  lfu,

  /// First In First Out - evicts oldest entries first
  fifo,

  /// Largest items are evicted first (good for size constraints)
  largestFirst,
}

/// Strategy for handling invalidation requests.
enum InvalidationStrategy {
  /// Invalidate only the exact matching key
  exact,

  /// Invalidate all keys matching a pattern (glob-like)
  pattern,

  /// Invalidate all keys with specific tags
  byTag,

  /// Invalidate all entries
  all,
}

/// Configuration for advanced cache manager.
final class AdvancedCacheConfig {
  const AdvancedCacheConfig({
    this.maxMemoryEntries = 1000,
    this.maxMemorySizeBytes,
    this.evictionStrategy = EvictionStrategy.lru,
    this.defaultTtl = const Duration(minutes: 5),
    this.enableStaleWhileRevalidate = true,
    this.maxStaleAge = const Duration(hours: 24),
    this.enableCacheWarming = false,
    this.enableStatistics = true,
    this.enableCompression = false,
    this.compressionThresholdBytes = 1024, // 1 KB
  });

  /// Create a config optimized for high-traffic scenarios
  factory AdvancedCacheConfig.highTraffic({
    Duration ttl = const Duration(minutes: 10),
  }) {
    return AdvancedCacheConfig(
      maxMemoryEntries: 5000,
      maxMemorySizeBytes: 100 * 1024 * 1024, // 100 MB
      evictionStrategy: EvictionStrategy.lfu,
      defaultTtl: ttl,
      enableCompression: true,
      compressionThresholdBytes: 512, // Compress anything over 512 bytes
    );
  }

  /// Create a config optimized for low-resource scenarios
  factory AdvancedCacheConfig.lowMemory({
    Duration ttl = const Duration(minutes: 3),
  }) {
    return AdvancedCacheConfig(
      maxMemoryEntries: 100,
      maxMemorySizeBytes: 5 * 1024 * 1024, // 5 MB
      evictionStrategy: EvictionStrategy.fifo,
      defaultTtl: ttl,
      enableStaleWhileRevalidate: false,
      enableStatistics: false,
    );
  }

  /// Create a config optimized for development
  factory AdvancedCacheConfig.development() {
    return const AdvancedCacheConfig(
      maxMemoryEntries: 500,
      maxMemorySizeBytes: 50 * 1024 * 1024, // 50 MB
      defaultTtl: Duration(minutes: 1),
      maxStaleAge: Duration(hours: 1),
    );
  }

  /// Maximum number of entries in memory cache
  final int maxMemoryEntries;

  /// Maximum size of memory cache in bytes
  final int? maxMemorySizeBytes;

  /// Eviction strategy to use when max entries is reached
  final EvictionStrategy evictionStrategy;

  /// Default time-to-live for cache entries (0 = no expiry)
  final Duration defaultTtl;

  /// Enable stale-while-revalidate pattern
  final bool enableStaleWhileRevalidate;

  /// Maximum age for serving stale data (if SWR enabled)
  final Duration? maxStaleAge;

  /// Enable automatic cache warming on startup
  final bool enableCacheWarming;

  /// Enable detailed statistics tracking
  final bool enableStatistics;

  /// Enable compression for cache entries
  final bool enableCompression;

  /// Compression threshold (only compress if larger than this)
  final int compressionThresholdBytes;
}
