import 'dart:async';

import '../library_exports.dart';

/// Cache middleware that implements read-through and write-through caching
/// using an [ICacheManager].
class CacheMiddleware implements IWordpressMiddleware {
  CacheMiddleware({
    required ICacheManager<WordpressRawResponse> cache,
    Duration ttl = const Duration(minutes: 1),
    bool clearOnWrite = true,
  })  : _cache = cache,
        _ttl = ttl,
        _clearOnWrite = clearOnWrite;

  final ICacheManager<WordpressRawResponse> _cache;
  final Duration _ttl;
  final bool _clearOnWrite;

  @override
  String get name => 'CacheMiddleware';

  @override
  Future<void> onLoad() async {}

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    return request;
  }

  @override
  Future<MiddlewareRawResponse> onExecute(WordpressRequest request) async {
    // Only cache GET requests
    if (request.method != HttpMethod.get) {
      return MiddlewareRawResponse.defaultInstance();
    }

    final key = _buildCacheKey(request);
    final hit = await _cache.get(key);
    if (hit == null) {
      return MiddlewareRawResponse.defaultInstance();
    }

    // Return cached payload through middleware
    return MiddlewareRawResponse(
      statusCode: hit.code,
      body: hit.data,
      headers: {
        ...hit.headers,
        'X-Cache': 'HIT',
      },
      message: hit.message,
      extra: hit.extra,
    );
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    // If response is from middleware cache, just return it.
    if (response.isMiddlewareResponse) {
      return response;
    }

    // Populate cache on successful GET
    final requestMethod = response.requestHeaders['method']?.toString();
    final requestUrl = response.requestHeaders['request-url']?.toString();
    if (requestMethod == HttpMethod.get.name && response.isSuccessful) {
      // Reconstruct a minimal request to create a key
      final key = _buildCacheKeyFromHeaders(
        response.requestHeaders,
        requestMethod!,
        requestUrl ?? '',
      );
      await _cache.set(key, response, expiry: _ttl);
      return response;
    }

    // Invalidate cache on successful write operations if configured
    final isWrite = requestMethod == HttpMethod.post.name ||
        requestMethod == HttpMethod.put.name ||
        requestMethod == HttpMethod.patch.name ||
        requestMethod == HttpMethod.delete.name;

    if (_clearOnWrite && isWrite && response.isSuccessful) {
      await _cache.clear();
    }

    return response;
  }

  @override
  Future<void> onUnload() async {}

  String _buildCacheKey(WordpressRequest request) {
    final qpEntries = (request.queryParameters ?? const <String, dynamic>{})
        .entries
        .where((e) => e.value != null)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final qpStr = qpEntries.map((e) => '${e.key}=${e.value}').join('&');

    // We do not have access to final resolved URL here, but request.url.toString()
    // is deterministic combined with base in execute; acceptable for a cache key.
    return '${request.method.name} ${request.url}|$qpStr|auth:${request.headers?['Authorization'] ?? ''}';
  }

  String _buildCacheKeyFromHeaders(
    Map<String, dynamic> headers,
    String method,
    String requestUrl,
  ) {
    final qp = headers['request-query']?.toString() ?? '';
    final auth = headers['Authorization']?.toString() ?? '';
    if (requestUrl.isNotEmpty) {
      return '$method $requestUrl|$qp|auth:$auth';
    }
    return '$method|$qp|auth:$auth';
  }
}
