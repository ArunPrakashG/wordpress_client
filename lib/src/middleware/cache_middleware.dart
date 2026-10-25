import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

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

    final key = _buildKey(
      method: request.extra[WordpressRequest.metaMethod],
      url: request.extra[WordpressRequest.metaUrl],
      query: request.extra[WordpressRequest.metaQuery],
      headers: request.headers,
    );
    if (key == null) {
      return MiddlewareRawResponse.defaultInstance();
    }

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

    final requestMethod = response.extra[WordpressRequest.metaMethod];

    // Populate cache on successful GET
    if (requestMethod == HttpMethod.get.name && response.isSuccessful) {
      final key = _buildKey(
        method: requestMethod,
        url: response.extra[WordpressRequest.metaUrl],
        query: response.extra[WordpressRequest.metaQuery],
        headers: response.requestHeaders,
      );
      if (key != null) {
        await _cache.set(key, response, expiry: _ttl);
      }
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

  /// Builds the cache key from request metadata, or null when it is missing.
  ///
  /// Both the lookup ([onExecute]) and the store ([onResponse]) go through this
  /// method so the two can never disagree. The credential is never part of the
  /// key itself, only a one-way digest of it, so persistent [ICacheManager]
  /// implementations do not end up storing secrets.
  String? _buildKey({
    required Object? method,
    required Object? url,
    required Object? query,
    required Map<String, dynamic>? headers,
  }) {
    if (method is! String || url is! String) {
      return null;
    }

    return '$method $url?${query ?? ''}|auth:${_authDigest(headers)}';
  }

  String _authDigest(Map<String, dynamic>? headers) {
    if (headers == null) {
      return 'none';
    }

    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization' && entry.value != null) {
        return sha256.convert(utf8.encode(entry.value.toString())).toString();
      }
    }

    return 'none';
  }
}
