import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wordpress_client/io.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late Directory dir;
  late MockWordpressAdapter adapter;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('wp_stores_');
    adapter = MockWordpressAdapter();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  final auth = WordpressAuth.appPassword(user: 'a', appPassword: 'secret-pw');

  test('queued writes survive a restart and flush afterwards', () async {
    final path = '${dir.path}/nested/queue.json';
    adapter.reply('POST', '/posts', MockResponse.connectionError());

    final before = OfflineWriteQueue(store: FileWriteQueueStore(path));
    final offline = makeClient(adapter, middlewares: [before], auth: auth);
    final response =
        await offline.posts.create(CreatePostRequest(title: 'Saved'));
    expect(response.wasQueued, isTrue);
    expect(File(path).readAsStringSync(), isNot(contains('secret-pw')));

    // A new app run: fresh queue, fresh client, same file.
    adapter = MockWordpressAdapter()
      ..reply('POST', '/posts', const MockResponse(body: onePost));
    final after = OfflineWriteQueue(store: FileWriteQueueStore(path));
    final online = makeClient(adapter, middlewares: [after], auth: auth);

    expect(await after.length, 1);
    final result = await after.flush(online);
    expect(result.sent.single.body, containsPair('title', 'Saved'));
    expect(await OfflineWriteQueue(store: FileWriteQueueStore(path)).length, 0);
  });

  test('cached responses survive a restart without saving credentials',
      () async {
    final path = '${dir.path}/cache.json';
    adapter.reply('GET', '/posts', const MockResponse(body: [onePost]));

    WordpressClient build() => makeClient(
          adapter,
          auth: auth,
          middlewares: [
            CacheMiddleware(
              cache: FileCacheStore(path),
              ttl: const Duration(minutes: 5),
            ),
          ],
        );

    final first = await build().posts.list(ListPostRequest());
    expect(first.isSuccessful, isTrue);
    final saved = File(path).readAsStringSync();
    expect(saved, isNot(contains('secret-pw')));
    expect(saved, isNot(contains(base64Credentials('a', 'secret-pw'))));

    final second = await build().posts.list(ListPostRequest());
    expect(second.headers['X-Cache'], 'HIT');
    expect((second as WordpressSuccessResponse<List<Post>>).data.single.id, 1);
    expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
  });

  test('a corrupt file starts empty instead of failing', () async {
    final path = '${dir.path}/queue.json';
    File(path).writeAsStringSync('{not json');

    expect(await FileWriteQueueStore(path).all(), isEmpty);
    expect(await FileCacheStore(path).get('missing'), isNull);
  });

  test('the cache keeps at most maxEntries, dropping the oldest', () async {
    String? saved;
    final store = JsonCacheStore(
      read: () async => saved,
      write: (json) async => saved = json,
      maxEntries: 2,
    );

    for (final key in ['a', 'b', 'c']) {
      await store.set(key, WordpressRawResponse(data: key, code: 200));
    }

    expect(await store.get('a'), isNull);
    expect((await store.get('c'))?.data, 'c');
    expect(saved, isNot(contains('"a"')));
  });
}

String base64Credentials(String user, String password) =>
    base64Encode(utf8.encode('$user:$password'));
