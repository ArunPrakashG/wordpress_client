import 'package:meta/meta.dart';

/// Represents an entry in the cache with a value and optional expiry time.
@immutable
class CacheEntry<T> {
  /// Creates a new [CacheEntry] with the given [value] and optional [expiryTime].
  ///
  /// [value] The data to be stored in the cache.
  /// [expiryTime] Optional. The time at which this entry should be considered expired.
  const CacheEntry(this.value, this.expiryTime);

  /// The data stored in this cache entry.
  final T value;

  /// The time at which this entry should be considered expired.
  /// If null, the entry does not expire.
  final DateTime? expiryTime;

  /// Checks if the cache entry has expired.
  ///
  /// Returns true if [expiryTime] is set and has passed, false otherwise.
  bool get isExpired =>
      expiryTime != null && DateTime.now().isAfter(expiryTime!);
}
