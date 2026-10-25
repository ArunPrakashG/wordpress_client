import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

/// A store that exposes its keys, like a disk or Redis backed one would.
final class _SpyStore extends MemoryCacheStore<WordpressRawResponse> {
  final List<String> keys = [];

  @override
  void set(String key, WordpressRawResponse value, {Duration? expiry}) {
    keys.add(key);
    super.set(key, value, expiry: expiry);
  }
}

/// Implements only the base interface, like a third party store might.
final class _PlainStore implements ICacheManager<WordpressRawResponse> {
  final Map<String, WordpressRawResponse> _entries = {};

  @override
  void set(String key, WordpressRawResponse value, {Duration? expiry}) =>
      _entries[key] = value;

  @override
  WordpressRawResponse? get(String key) => _entries[key];

  @override
  void remove(String key) => _entries.remove(key);

  @override
  void clear() => _entries.clear();
}

void main() {
  late MockWordpressAdapter adapter;
  late _SpyStore store;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply('GET', '/posts', const MockResponse(body: [onePost]))
      ..reply('GET', '/pages', const MockResponse(body: []))
      ..reply(
        'POST',
        '/posts',
        const MockResponse(statusCode: 201, body: onePost),
      );
    store = _SpyStore();
  });

  WordpressClient clientWithCache({
    IAuthorization? auth,
    bool clearOnWrite = true,
    CacheInvalidation invalidation = CacheInvalidation.resource,
    Duration? Function(Uri url)? ttlFor,
    bool Function(WordpressRawResponse response)? shouldCache,
    ICacheManager<WordpressRawResponse>? cache,
  }) {
    return makeClient(
      adapter,
      auth: auth,
      middlewares: [
        CacheMiddleware(
          cache: cache ?? store,
          clearOnWrite: clearOnWrite,
          invalidation: invalidation,
          ttlFor: ttlFor,
          shouldCache: shouldCache,
        ),
      ],
    );
  }

  group('read-through (#84)', () {
    test('second identical GET is served from cache', () async {
      final client = clientWithCache();

      final first = await client.posts.list(ListPostRequest());
      final second = await client.posts.list(ListPostRequest());

      expect(first, isA<WordpressSuccessResponse<List<Post>>>());
      expect(second, isA<WordpressSuccessResponse<List<Post>>>());
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
      expect(second.headers['X-Cache'], 'HIT');
    });

    test('different query parameters do not share an entry', () async {
      final client = clientWithCache();

      await client.posts.list(ListPostRequest(perPage: 5));
      await client.posts.list(ListPostRequest(perPage: 6));

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });

    test('different credentials do not share an entry', () async {
      final a = clientWithCache(
        auth: WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1'),
      );
      final b = clientWithCache(
        auth: WordpressAuth.appPassword(user: 'b', appPassword: 'pw2 pw2'),
      );

      await a.posts.list(ListPostRequest(requireAuth: true));
      await b.posts.list(ListPostRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });

    test('a successful write clears the cache', () async {
      final client = clientWithCache(
        auth: WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1'),
      );

      await client.posts.list(ListPostRequest(requireAuth: true));
      await client.posts.create(
        CreatePostRequest(title: 'x', content: 'y', status: 'draft'),
      );
      await client.posts.list(ListPostRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });

    test('failed responses are not cached', () async {
      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(statusCode: 500, code: 'boom'),
      );
      final client = clientWithCache();

      await client.posts.list(ListPostRequest());
      await client.posts.list(ListPostRequest());

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });
  });

  group('resource invalidation (#90)', () {
    final auth = WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1');

    Future<void> createPost(WordpressClient client) {
      return client.posts.create(
        CreatePostRequest(title: 'x', content: 'y', status: 'draft'),
      );
    }

    test('a write evicts its own resource but not others', () async {
      final client = clientWithCache(auth: auth);

      await client.posts.list(ListPostRequest(requireAuth: true));
      await client.pages.list(ListPageRequest(requireAuth: true));
      await createPost(client);
      await client.posts.list(ListPostRequest(requireAuth: true));
      await client.pages.list(ListPageRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
      expect(adapter.callCount(method: 'GET', path: '/pages'), 1);
    });

    test('invalidation: all evicts every resource', () async {
      final client = clientWithCache(
        auth: auth,
        invalidation: CacheInvalidation.all,
      );

      await client.pages.list(ListPageRequest(requireAuth: true));
      await createPost(client);
      await client.pages.list(ListPageRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/pages'), 2);
    });

    test('a store without removeWhere falls back to clearing', () async {
      final client = clientWithCache(auth: auth, cache: _PlainStore());

      await client.pages.list(ListPageRequest(requireAuth: true));
      await createPost(client);
      await client.pages.list(ListPageRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/pages'), 2);
    });

    test('clearOnWrite: false keeps everything', () async {
      final client = clientWithCache(auth: auth, clearOnWrite: false);

      await client.posts.list(ListPostRequest(requireAuth: true));
      await createPost(client);
      await client.posts.list(ListPostRequest(requireAuth: true));

      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
    });

    test('shouldCache can veto storing a response', () async {
      final client = clientWithCache(shouldCache: (_) => false);

      await client.posts.list(ListPostRequest());
      await client.posts.list(ListPostRequest());

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });

    test('ttlFor sets a per-endpoint time to live', () async {
      final client = clientWithCache(
        ttlFor: (url) => url.path.endsWith('/posts') ? Duration.zero : null,
      );

      await client.posts.list(ListPostRequest());
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await client.posts.list(ListPostRequest());
      await client.pages.list(ListPageRequest());
      await client.pages.list(ListPageRequest());

      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
      expect(adapter.callCount(method: 'GET', path: '/pages'), 1);
    });
  });

  group('cache keys (#89)', () {
    test('never contain the raw credential', () async {
      final client = clientWithCache(
        auth: WordpressAuth.appPassword(
          user: 'alice',
          appPassword: 'sekret sekret',
        ),
      );
      await client.posts.list(ListPostRequest(requireAuth: true));

      final raw = adapter.lastRequest!.headers['Authorization'] as String;
      expect(raw, startsWith('Basic '));
      expect(store.keys, isNotEmpty);
      for (final key in store.keys) {
        expect(key, isNot(contains(raw)));
        expect(key, isNot(contains(raw.substring(6))));
        expect(key, isNot(contains('sekret')));
      }
    });
  });
}
