import 'dart:async';

/// An abstract class defining the interface for a cache manager.
///
/// This interface provides methods for basic cache operations such as
/// setting, getting, removing, and clearing cache entries.
abstract class ICacheManager<T> {
  const ICacheManager();

  /// Stores a value in the cache with the specified key.
  ///
  /// [key] The unique identifier for the cache entry.
  /// [value] The value to be stored in the cache.
  /// [expiry] Optional duration after which the cache entry should expire.
  FutureOr<void> set(String key, T value, {Duration? expiry});

  /// Retrieves a value from the cache using the specified key.
  ///
  /// [key] The unique identifier for the cache entry.
  /// [T] The expected type of the cached value.
  ///
  /// Returns a [FutureOr] that resolves to the cached value of type [T].
  FutureOr<T?> get(String key);

  /// Removes a specific entry from the cache.
  ///
  /// [key] The unique identifier of the cache entry to be removed.
  FutureOr<void> remove(String key);

  /// Clears all entries from the cache.
  FutureOr<void> clear();
}
