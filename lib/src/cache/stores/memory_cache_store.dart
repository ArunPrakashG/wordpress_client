import '../cache_entry.dart';
import '../cache_manager_base.dart';

class MemoryCacheStore<T> implements ICacheManager<T> {
  MemoryCacheStore();

  final Map<String, CacheEntry<T>> _cache = {};

  @override
  void set(String key, T value, {Duration? expiry}) {
    final expiryTime = expiry != null ? DateTime.now().add(expiry) : null;
    _cache[key] = CacheEntry(value, expiryTime);
  }

  @override
  T? get(String key) {
    final entry = _cache[key];

    if (entry == null || entry.isExpired) {
      _cache.remove(key);

      return null;
    }

    return entry.value;
  }

  @override
  void remove(String key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }
}
