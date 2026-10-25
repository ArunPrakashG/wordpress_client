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
  }) {
    return makeClient(
      adapter,
      auth: auth,
      middlewares: [CacheMiddleware(cache: store, clearOnWrite: clearOnWrite)],
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
