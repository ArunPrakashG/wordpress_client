import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;
  late MemoryWriteQueueStore store;
  late OfflineWriteQueue queue;
  late WordpressClient client;

  WordpressClient build(OfflineWriteQueue q) => makeClient(
        adapter,
        middlewares: [q],
        auth: WordpressAuth.appPassword(user: 'a', appPassword: 'b'),
      );

  setUp(() {
    adapter = MockWordpressAdapter();
    store = MemoryWriteQueueStore();
    queue = OfflineWriteQueue(store: store);
    client = build(queue);
  });

  test('a write that fails offline is queued and flagged', () async {
    adapter.reply('POST', '/posts', MockResponse.connectionError());

    final response = await client.posts.create(CreatePostRequest(title: 'A'));

    expect(response.isFailure, isTrue);
    expect(response.wasQueued, isTrue);
    final pending = await queue.pending;
    expect(pending, hasLength(1));
    expect(pending.single.method, 'post');
    expect(pending.single.body, containsPair('title', 'A'));
  });

  test('reads, timeouts and server errors are not queued', () async {
    adapter
      ..reply('GET', '/posts', MockResponse.connectionError())
      ..reply('POST', '/posts', MockResponse.timeout())
      ..reply(
        'DELETE',
        '/posts/3',
        MockResponse.wpError(statusCode: 403, code: 'rest_forbidden'),
      );

    final read = await client.posts.list(ListPostRequest());
    final timeout = await client.posts.create(CreatePostRequest(title: 'A'));
    final denied = await client.posts.delete(DeletePostRequest(id: 3));

    expect(read.wasQueued, isFalse);
    expect(timeout.wasQueued, isFalse);
    expect(denied.wasQueued, isFalse);
    expect(await queue.length, 0);
  });

  test('timeouts are queued when asked for', () async {
    queue = OfflineWriteQueue(store: store, queueOnTimeout: true);
    client = build(queue);
    adapter.reply('POST', '/posts', MockResponse.timeout());

    final response = await client.posts.create(CreatePostRequest(title: 'A'));

    expect(response.wasQueued, isTrue);
  });

  test('flush replays in order, drops refusals and keeps order offline',
      () async {
    adapter.reply('POST', '/posts', MockResponse.connectionError());
    await client.posts.create(CreatePostRequest(title: 'first'));
    await client.posts.create(CreatePostRequest(title: 'second'));
    await client.posts.create(CreatePostRequest(title: 'third'));
    expect(await queue.length, 3);

    // Still offline: nothing is lost, nothing is re-queued.
    adapter.clearRequests();
    var result = await queue.flush(client);
    expect(result.sent, isEmpty);
    expect(result.remaining, 3);
    expect(adapter.callCount(method: 'POST', path: '/posts'), 1);
    expect(await queue.length, 3);

    // Back online: the second one is refused for good.
    var call = 0;
    adapter.on('POST', '/posts', (req) {
      call++;
      return call == 2
          ? MockResponse.wpError(statusCode: 400, code: 'rest_invalid_param')
          : const MockResponse(statusCode: 201, body: onePost);
    });
    adapter.clearRequests();

    result = await queue.flush(client);

    expect(result.sent.map((w) => (w.body as Map)['title']), [
      'first',
      'third',
    ]);
    expect(result.rejected.single.write.body, containsPair('title', 'second'));
    expect(result.rejected.single.response.code, 400);
    expect(result.isDrained, isTrue);
    expect(adapter.callCount(method: 'POST', path: '/posts'), 3);
    expect(await queue.length, 0);
  });

  test('a server error stops the flush and keeps the rest', () async {
    adapter.reply('POST', '/posts', MockResponse.connectionError());
    await client.posts.create(CreatePostRequest(title: 'a'));
    await client.posts.create(CreatePostRequest(title: 'b'));

    adapter.reply(
      'POST',
      '/posts',
      MockResponse.wpError(statusCode: 503, code: 'busy'),
    );
    final result = await queue.flush(client);

    expect(result.sent, isEmpty);
    expect(result.rejected, isEmpty);
    expect(result.remaining, 2);
  });

  test('maxLength caps the queue; writes round trip through json', () async {
    queue = OfflineWriteQueue(store: store, maxLength: 1);
    client = build(queue);
    adapter.reply('POST', '/posts', MockResponse.connectionError());

    final first = await client.posts.create(CreatePostRequest(title: 'a'));
    final second = await client.posts.create(CreatePostRequest(title: 'b'));

    expect(first.wasQueued, isTrue);
    expect(second.wasQueued, isFalse);

    final write = (await queue.pending).single;
    final restored = QueuedWrite.fromJson(write.toJson());
    expect(restored.id, write.id);
    expect(restored.toRequest().method, HttpMethod.post);
    expect(restored.body, write.body);
  });
}
