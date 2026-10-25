import '../cache_entry.dart';
import '../selective_cache.dart';

class MemoryCacheStore<T> implements ISelectiveCache<T> {
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
  void removeWhere(bool Function(String key) test) {
    _cache.removeWhere((key, _) => test(key));
  }

  @override
  void clear() {
    _cache.clear();
  }
}
