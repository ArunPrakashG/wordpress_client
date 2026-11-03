import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;
  late WordpressClient client;

  final edited = DateTime.parse('2024-01-02T10:00:00');

  setUp(() {
    adapter = MockWordpressAdapter();
    client = makeClient(
      adapter,
      auth: WordpressAuth.appPassword(user: 'a', appPassword: 'b'),
      middlewares: [CacheMiddleware(cache: MemoryCacheStore())],
    );
  });

  void serverModified(String value) {
    adapter.reply(
      'GET',
      '/posts/1',
      MockResponse(body: {'modified_gmt': value}),
    );
  }

  test('sends the update when the item is unchanged', () async {
    serverModified('2024-01-02T10:00:00');
    adapter.reply('POST', '/posts/1', const MockResponse(body: onePost));

    final response = await client.posts.updateIfUnmodified(
      UpdatePostRequest(id: 1, title: 'New'),
      lastModifiedGmt: edited,
    );

    expect(response.isSuccessful, isTrue);
    final check = adapter.requests.first;
    expect(check.method, 'GET');
    expect(check.uri.queryParameters['_fields'], 'modified_gmt');
    expect(adapter.callCount(method: 'POST', path: '/posts/1'), 1);
  });

  test('a UTC DateTime with the same digits counts as unchanged', () async {
    serverModified('2024-01-02T10:00:00');
    adapter.reply('POST', '/posts/1', const MockResponse(body: onePost));

    final response = await client.posts.updateIfUnmodified(
      UpdatePostRequest(id: 1, title: 'New'),
      lastModifiedGmt: DateTime.utc(2024, 1, 2, 10),
    );

    expect(response.isSuccessful, isTrue);
  });

  test('returns a conflict and sends nothing when someone else saved',
      () async {
    serverModified('2024-01-02T10:05:00');

    final response = await client.posts.updateIfUnmodified(
      UpdatePostRequest(id: 1, title: 'New'),
      lastModifiedGmt: edited,
    );

    expect(response, isA<WordpressFailureResponse<Post>>());
    final failure = response as WordpressFailureResponse<Post>;
    expect(failure.code, 409);
    expect(failure.error?.code, UpdateOperation.conflictErrorCode);
    expect(adapter.callCount(method: 'POST'), 0);
  });

  test('the check is never answered from the cache', () async {
    serverModified('2024-01-02T10:00:00');
    adapter.reply('POST', '/posts/1', const MockResponse(body: onePost));
    final request = UpdatePostRequest(id: 1, title: 'New');

    await client.posts.updateIfUnmodified(request, lastModifiedGmt: edited);
    serverModified('2024-01-02T11:00:00');
    final second =
        await client.posts.updateIfUnmodified(request, lastModifiedGmt: edited);

    expect(second.code, 409);
    expect(adapter.callCount(method: 'GET', path: '/posts/1'), 2);
  });

  test('items without modified_gmt fail clearly', () async {
    adapter.reply(
        'GET', '/posts/1', const MockResponse(body: <String, dynamic>{}));

    final response = await client.posts.updateIfUnmodified(
      UpdatePostRequest(id: 1, title: 'New'),
      lastModifiedGmt: edited,
    );

    expect(response.code, 412);
    expect(
      (response as WordpressFailureResponse).error?.code,
      UpdateOperation.noModifiedErrorCode,
    );
  });

  test('a failed check is returned as is', () async {
    adapter.reply(
      'GET',
      '/posts/1',
      MockResponse.wpError(statusCode: 404, code: 'rest_post_invalid_id'),
    );

    final response = await client.posts.updateIfUnmodified(
      UpdatePostRequest(id: 1, title: 'New'),
      lastModifiedGmt: edited,
    );

    expect(response.code, 404);
    expect(adapter.callCount(method: 'POST'), 0);
  });
}
