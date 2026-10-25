import 'dart:async';

import 'cache_manager_base.dart';

/// An [ICacheManager] that can drop a group of entries at once.
///
/// `CacheMiddleware` uses this to invalidate only the resource that was
/// written (for example every cached `posts` response after a post is
/// created) instead of throwing the whole cache away. Stores that do not
/// implement it keep working: the middleware falls back to [ICacheManager.clear].
abstract interface class ISelectiveCache<T> implements ICacheManager<T> {
  /// Removes every entry whose key satisfies [test].
  FutureOr<void> removeWhere(bool Function(String key) test);
}
