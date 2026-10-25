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
    this.revalidateWindow = const Duration(hours: 1),
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

  /// How long after its time to live an entry is kept for revalidation.
  ///
  /// When a cached response carries an `ETag` or `Last-Modified` header and
  /// expires, the next request is sent with `If-None-Match` /
  /// `If-Modified-Since`; a `304 Not Modified` answer revives the cached body
  /// without downloading it again. Set to [Duration.zero] to turn this off.
  /// Entries without a validator are dropped at their time to live as before.
  final Duration revalidateWindow;

  static const String _storedAtKey = 'wp.cache.storedAt';
  static const String _ttlKey = 'wp.cache.ttl';

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

    if (!_isFresh(hit)) {
      final validators = _validators(hit.headers);

      return MiddlewareRawResponse(
        statusCode: -99,
        body: null,
        requestHeaders: validators.isEmpty ? null : validators,
      );
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

    if (requestMethod == HttpMethod.get.name) {
      final url = response.extra[WordpressRequest.metaUrl];
      final key = _buildKey(
        method: requestMethod,
        url: url,
        query: response.extra[WordpressRequest.metaQuery],
        headers: response.requestHeaders,
      );

      // 304 Not Modified: the cached body is still valid, so refresh it.
      if (response.code == 304 && key != null) {
        final cached = await _cache.get(key);
        if (cached != null) {
          return _store(
            key,
            cached.copyWith(
              headers: {...cached.headers, ...response.headers},
              duration: response.duration,
              extra: {...cached.extra, ...response.extra},
            ),
            url,
            header: 'REVALIDATED',
          );
        }
      }

      // Populate cache on successful GET
      if (response.code >= 200 && response.code < 300) {
        if (key != null && (shouldCache?.call(response) ?? true)) {
          await _store(key, response, url);
        }
        return response;
      }
    }

    // Invalidate cache on successful write operations if configured
    final isWrite = requestMethod == HttpMethod.post.name ||
        requestMethod == HttpMethod.put.name ||
        requestMethod == HttpMethod.patch.name ||
        requestMethod == HttpMethod.delete.name;

    final keepCache = response.extra[WordpressRequest.metaKeepCache] == true;

    if (_clearOnWrite && isWrite && !keepCache && response.isSuccessful) {
      await _invalidate(response.extra[WordpressRequest.metaUrl]);
    }

    return response;
  }

  /// Stamps [response] with its freshness window and stores it.
  ///
  /// With a validator the entry outlives its time to live by
  /// [revalidateWindow] so it can be revalidated instead of refetched.
  Future<WordpressRawResponse> _store(
    String key,
    WordpressRawResponse response,
    Object? url, {
    String? header,
  }) async {
    final ttl = (url is String ? ttlFor?.call(Uri.parse(url)) : null) ?? _ttl;
    final keep = _validators(response.headers).isEmpty
        ? Duration.zero
        : revalidateWindow;

    final stamped = response.copyWith(
      extra: {
        ...response.extra,
        _storedAtKey: DateTime.now().millisecondsSinceEpoch,
        _ttlKey: ttl.inMilliseconds,
      },
    );
    await _cache.set(key, stamped, expiry: ttl + keep);

    if (header == null) {
      return response;
    }

    return stamped.copyWith(
      code: 200,
      headers: {...stamped.headers, 'X-Cache': header},
    );
  }

  bool _isFresh(WordpressRawResponse entry) {
    final storedAt = entry.extra[_storedAtKey];
    final ttl = entry.extra[_ttlKey];
    if (storedAt is! int || ttl is! int) {
      return true;
    }

    return DateTime.now().millisecondsSinceEpoch - storedAt <= ttl;
  }

  /// The conditional request headers for a cached response, if it has any
  /// validator (`ETag` / `Last-Modified`).
  Map<String, String> _validators(Map<String, dynamic> headers) {
    String? find(String name) {
      for (final entry in headers.entries) {
        if (entry.key.toLowerCase() == name && entry.value != null) {
          final value = entry.value;

          return value is List ? value.firstOrNull?.toString() : '$value';
        }
      }

      return null;
    }

    final etag = find('etag');
    final modified = find('last-modified');

    return {
      if (etag != null) 'If-None-Match': etag,
      if (modified != null) 'If-Modified-Since': modified,
    };
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
