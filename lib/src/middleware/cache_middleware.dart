import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../library_exports.dart';

/// What a successful write (POST/PUT/PATCH/DELETE) evicts from the cache.
enum CacheInvalidation {
  /// Evict only the cached GET responses of the resource that was written:
  /// writing `/wp/v2/posts/5` evicts `/wp/v2/posts`, `/wp/v2/posts/5`,
  /// `/wp/v2/posts/5/revisions`, and so on, but leaves `/wp/v2/pages` alone.
  ///
  /// Falls back to [all] when the URL is not a REST route or the store does
  /// not implement [ISelectiveCache].
  resource,

  /// Evict everything.
  all,
}

/// Cache middleware that implements read-through and write-through caching
/// using an [ICacheManager].
class CacheMiddleware implements IWordpressMiddleware {
  CacheMiddleware({
    required ICacheManager<WordpressRawResponse> cache,
    Duration ttl = const Duration(minutes: 1),
    bool clearOnWrite = true,
    this.invalidation = CacheInvalidation.resource,
    this.ttlFor,
    this.shouldCache,
  })  : _cache = cache,
        _ttl = ttl,
        _clearOnWrite = clearOnWrite;

  final ICacheManager<WordpressRawResponse> _cache;
  final Duration _ttl;
  final bool _clearOnWrite;

  /// How much of the cache a successful write evicts. Ignored when
  /// `clearOnWrite` is false.
  final CacheInvalidation invalidation;

  /// Picks a time to live per request URL, for example a longer one for
  /// rarely changing `categories`. Return null to use the default `ttl`.
  final Duration? Function(Uri url)? ttlFor;

  /// Decides whether a successful GET response is stored. Return false to
  /// skip it, for example for endpoints that must always be fresh.
  final bool Function(WordpressRawResponse response)? shouldCache;

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
      final url = response.extra[WordpressRequest.metaUrl];
      final allowed = shouldCache?.call(response) ?? true;
      if (key != null && allowed) {
        final ttl = url is String ? ttlFor?.call(Uri.parse(url)) : null;
        await _cache.set(key, response, expiry: ttl ?? _ttl);
      }
      return response;
    }

    // Invalidate cache on successful write operations if configured
    final isWrite = requestMethod == HttpMethod.post.name ||
        requestMethod == HttpMethod.put.name ||
        requestMethod == HttpMethod.patch.name ||
        requestMethod == HttpMethod.delete.name;

    if (_clearOnWrite && isWrite && response.isSuccessful) {
      await _invalidate(response.extra[WordpressRequest.metaUrl]);
    }

    return response;
  }

  Future<void> _invalidate(Object? writtenUrl) async {
    final cache = _cache;
    final root =
        invalidation == CacheInvalidation.resource && writtenUrl is String
            ? _resourceRoot(writtenUrl)
            : null;

    if (root == null || cache is! ISelectiveCache<WordpressRawResponse>) {
      await cache.clear();
      return;
    }

    // Keys look like `get <url>?<query>|auth:<digest>`.
    final prefix = 'get $root';
    await cache.removeWhere((key) {
      if (!key.startsWith(prefix) || key.length == prefix.length) {
        return false;
      }
      final next = key[prefix.length];

      return next == '?' || next == '/';
    });
  }

  /// The URL of the resource collection a write belongs to, e.g.
  /// `https://x.com/wp-json/wp/v2/posts` for `.../wp/v2/posts/5`.
  ///
  /// REST routes are `wp-json/<vendor>/<version>/<resource>/...`. Returns null
  /// when the URL does not follow that shape.
  static String? _resourceRoot(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    final marker = segments.indexOf('wp-json');
    if (marker < 0 || segments.length < marker + 4) {
      return null;
    }

    return uri
        .replace(
          pathSegments: segments.sublist(0, marker + 4),
          query: '',
        )
        .toString()
        .replaceAll(RegExp(r'\?$'), '');
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
