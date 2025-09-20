import '../../wordpress_client.dart';

/// Contract for per-interface convenience helpers.
abstract interface class IInterfaceExtensions<TModel, TId> {
  /// Retrieve a single resource by id (int, string, or other identifier shape).
  Future<WordpressResponse<TModel>> getById(TId id, {RequestContext? context});
}

// Per-interface concrete holders will implement IInterfaceExtensions and be exposed via
// a getter on each interface (e.g., posts.extensions)
