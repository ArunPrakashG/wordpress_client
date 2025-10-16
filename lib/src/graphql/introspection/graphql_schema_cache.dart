import '../../cache/advanced_cache_manager.dart';
import 'graphql_introspection.dart';

/// GraphQL Schema cache entry with TTL support
class GraphQLSchemaCacheEntry {
  GraphQLSchemaCacheEntry({
    required this.schema,
    required this.ttlSeconds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// The cached schema
  final GraphQLSchema schema;

  /// When the cache entry was created
  final DateTime createdAt;

  /// Time-to-live in seconds
  final int ttlSeconds;

  /// Check if this cache entry is still valid
  bool get isValid {
    final now = DateTime.now();
    final expiresAt = createdAt.add(Duration(seconds: ttlSeconds));
    return now.isBefore(expiresAt);
  }

  /// Get remaining TTL in seconds
  int get remainingTtl {
    final now = DateTime.now();
    final expiresAt = createdAt.add(Duration(seconds: ttlSeconds));
    final remaining = expiresAt.difference(now).inSeconds;
    return remaining.isNegative ? 0 : remaining;
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() => {
        'types': schema.types,
        'queryType': schema.queryType,
        'mutationType': schema.mutationType,
        'subscriptionType': schema.subscriptionType,
        'directives': schema.directives,
      };
}

/// Configuration for GraphQL schema caching
class GraphQLSchemaCacheConfig {
  GraphQLSchemaCacheConfig({
    this.cacheKey = 'graphql_schema',
    this.defaultTtlSeconds = 3600,
    this.invalidateOnError = true,
    this.maxCacheRevisions = 5,
  });

  /// Cache key for storing schemas
  final String cacheKey;

  /// Default TTL in seconds (default: 3600 = 1 hour)
  final int defaultTtlSeconds;

  /// Enable automatic cache invalidation on fetch errors
  final bool invalidateOnError;

  /// Maximum number of schema revisions to keep
  final int maxCacheRevisions;
}

/// Exception thrown by GraphQL schema cache operations
class GraphQLSchemaCacheException implements Exception {
  GraphQLSchemaCacheException(
    this.message, {
    this.cause,
  });

  final String message;
  final Exception? cause;

  @override
  String toString() =>
      'GraphQLSchemaCacheException: $message${cause != null ? ' | Caused by: $cause' : ''}';
}

/// GraphQL Schema caching layer with TTL and integration to AdvancedCacheManager
///
/// This class provides caching capabilities for GraphQL schemas fetched via introspection.
/// It integrates with the AdvancedCacheManager to provide TTL-based caching,
/// cache invalidation, and statistics tracking.
///
/// Example:
/// ```dart
/// final cacheManager = AdvancedCacheManager();
/// final schemaCache = GraphQLSchemaCache(
///   cacheManager: cacheManager,
///   introspection: introspection,
///   config: GraphQLSchemaCacheConfig(defaultTtlSeconds: 3600),
/// );
///
/// // Fetch with automatic caching
/// final schema = await schemaCache.getSchema();
/// ```
class GraphQLSchemaCache {
  GraphQLSchemaCache({
    required this.cacheManager,
    required this.introspection,
    GraphQLSchemaCacheConfig? config,
  }) : config = config ?? GraphQLSchemaCacheConfig();

  /// The underlying cache manager
  final AdvancedCacheManager cacheManager;

  /// The introspection executor
  final GraphQLIntrospection introspection;

  /// Cache configuration
  final GraphQLSchemaCacheConfig config;

  /// Internal cache of schemas keyed by endpoint URL
  final Map<String, GraphQLSchemaCacheEntry> _endpointSchemas = {};

  /// Get or fetch a schema with caching
  ///
  /// First checks the in-memory cache, then the persistent cache,
  /// then fetches fresh from the introspection query.
  ///
  /// Throws [GraphQLSchemaCacheException] if all retrieval methods fail.
  Future<GraphQLSchema> getSchema({
    String? cacheKey,
    int? ttlSeconds,
  }) async {
    final key = cacheKey ?? config.cacheKey;
    final ttl = ttlSeconds ?? config.defaultTtlSeconds;

    try {
      // Check in-memory cache first
      final memoryEntry = _endpointSchemas[key];
      if (memoryEntry != null && memoryEntry.isValid) {
        return memoryEntry.schema;
      }

      // Check persistent cache
      final cachedSchema = await _getCachedSchema(key);
      if (cachedSchema != null) {
        _endpointSchemas[key] = GraphQLSchemaCacheEntry(
          schema: cachedSchema,
          ttlSeconds: ttl,
        );
        return cachedSchema;
      }

      // Fetch fresh schema
      final schema = await introspection.fetchSchema();

      // Cache the schema
      await _cacheSchema(key, schema, ttl);

      // Update in-memory cache
      _endpointSchemas[key] = GraphQLSchemaCacheEntry(
        schema: schema,
        ttlSeconds: ttl,
      );

      return schema;
    } catch (e) {
      throw GraphQLSchemaCacheException(
        'Failed to get schema for key: $key',
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get cached schema from persistent storage
  Future<GraphQLSchema?> _getCachedSchema(String key) async {
    try {
      // The cache stores the entire schema object
      final cached = await cacheManager.get(key);
      if (cached is GraphQLSchema) {
        return cached;
      }
      return null;
    } catch (e) {
      // Return null if retrieval fails
      return null;
    }
  }

  /// Cache a schema in persistent storage
  Future<void> _cacheSchema(
    String key,
    GraphQLSchema schema,
    int ttlSeconds,
  ) async {
    try {
      await cacheManager.set(
        key,
        schema,
        expiry: Duration(seconds: ttlSeconds),
      );
    } catch (e) {
      // Log but don't throw - caching failure shouldn't break the flow
      // In production, this would use a proper logger
    }
  }

  /// Invalidate schema cache
  ///
  /// Removes the schema from both in-memory and persistent caches.
  Future<void> invalidateSchema({String? cacheKey}) async {
    final key = cacheKey ?? config.cacheKey;

    // Remove from in-memory cache
    _endpointSchemas.remove(key);

    // Remove from persistent cache
    try {
      await cacheManager.remove(key);
    } catch (e) {
      // Ignore removal errors
    }
  }

  /// Invalidate all cached schemas
  Future<void> invalidateAllSchemas() async {
    _endpointSchemas.clear();
    try {
      await cacheManager.clear();
    } catch (e) {
      // Ignore clear errors
    }
  }

  /// Get cache statistics
  ///
  /// Returns information about the current cache state including
  /// number of cached schemas and their TTL status.
  GraphQLSchemaCacheStats getStats() {
    final totalCached = _endpointSchemas.length;
    final validCached =
        _endpointSchemas.values.where((entry) => entry.isValid).length;
    final expiredCached = totalCached - validCached;

    final remainingTtls =
        _endpointSchemas.values.map((entry) => entry.remainingTtl).toList();

    final avgRemainingTtl = remainingTtls.isEmpty
        ? 0
        : remainingTtls.reduce((a, b) => a + b) ~/ remainingTtls.length;

    return GraphQLSchemaCacheStats(
      totalCached: totalCached,
      validCached: validCached,
      expiredCached: expiredCached,
      averageRemainingTtl: avgRemainingTtl,
    );
  }

  /// Check if a schema is cached and valid
  bool isSchemaCached({String? cacheKey}) {
    final key = cacheKey ?? config.cacheKey;
    final entry = _endpointSchemas[key];
    return entry != null && entry.isValid;
  }

  /// Get remaining TTL for a cached schema
  int getRemainingTtl({String? cacheKey}) {
    final key = cacheKey ?? config.cacheKey;
    final entry = _endpointSchemas[key];
    return entry?.remainingTtl ?? 0;
  }

  /// Refresh a schema (force fetch from introspection)
  ///
  /// Invalidates the current cache and fetches a fresh schema.
  Future<GraphQLSchema> refreshSchema({
    String? cacheKey,
    int? ttlSeconds,
  }) async {
    await invalidateSchema(cacheKey: cacheKey);
    return getSchema(cacheKey: cacheKey, ttlSeconds: ttlSeconds);
  }
}

/// Statistics for GraphQL schema cache
class GraphQLSchemaCacheStats {
  GraphQLSchemaCacheStats({
    required this.totalCached,
    required this.validCached,
    required this.expiredCached,
    required this.averageRemainingTtl,
  });

  /// Total number of cached schemas
  final int totalCached;

  /// Number of valid (non-expired) cached schemas
  final int validCached;

  /// Number of expired cached schemas
  final int expiredCached;

  /// Average remaining TTL in seconds across all valid caches
  final int averageRemainingTtl;

  /// Get cache hit rate as a percentage
  double get hitRate =>
      totalCached == 0 ? 0 : (validCached / totalCached) * 100;

  @override
  String toString() =>
      'GraphQLSchemaCacheStats(total: $totalCached, valid: $validCached, expired: $expiredCached, avgTtl: ${averageRemainingTtl}s, hitRate: ${hitRate.toStringAsFixed(2)}%)';
}
