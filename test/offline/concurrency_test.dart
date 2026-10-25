import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

WordpressClient build(
  MockWordpressAdapter adapter,
  BootstrapConfiguration Function(BootstrapBuilder) configure,
) {
  return WordpressClient.fromDioInstance(
    baseUrl: testBaseUrl,
    instance: Dio()..httpClientAdapter = adapter,
    bootstrapper: configure,
  );
}

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply(
        'GET',
        '/posts',
        MockResponse.paged(
          [onePost],
          total: 1,
          totalPages: 1,
          delay: const Duration(milliseconds: 150),
        ),
      )
      ..reply(
        'POST',
        '/posts',
        const MockResponse(
          body: onePost,
          delay: Duration(milliseconds: 50),
        ),
      );
  });

  group('request deduplication', () {
    test('identical concurrent GETs share one network call', () async {
      final client = build(
        adapter,
        (b) => b.withRequestDeduplication().build(),
      );

      final results = await Future.wait([
        client.posts.list(ListPostRequest(perPage: 5)),
        client.posts.list(ListPostRequest(perPage: 5)),
        client.posts.list(ListPostRequest(perPage: 5)),
      ]);

      expect(results.every((r) => r.isSuccessful), isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
    });

    test('different queries, writes and cancellable requests are not shared',
        () async {
      final client = build(
        adapter,
        (b) => b
            .withRequestDeduplication()
            .withDefaultAuthorization(
              WordpressAuth.appPassword(user: 'a', appPassword: 'b'),
            )
            .build(),
      );

      await Future.wait([
        client.posts.list(ListPostRequest(perPage: 5)),
        client.posts.list(ListPostRequest(perPage: 6)),
        client.posts
            .list(ListPostRequest(perPage: 5, cancelToken: CancelToken())),
        client.posts
            .list(ListPostRequest(perPage: 5, cancelToken: CancelToken())),
      ]);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 4);

      await Future.wait([
        client.posts.create(CreatePostRequest(title: 'a')),
        client.posts.create(CreatePostRequest(title: 'a')),
      ]);
      expect(adapter.callCount(method: 'POST', path: '/posts'), 2);
    });

    test('is off by default, and a finished call is not reused', () async {
      final plain = build(adapter, (b) => b.build());
      await Future.wait([
        plain.posts.list(ListPostRequest()),
        plain.posts.list(ListPostRequest()),
      ]);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);

      adapter.clearRequests();
      final client = build(
        adapter,
        (b) => b.withRequestDeduplication().build(),
      );
      await client.posts.list(ListPostRequest());
      await client.posts.list(ListPostRequest());
      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });
  });

  group('max concurrent requests', () {
    Future<Duration> timeFour(WordpressClient client) async {
      final watch = Stopwatch()..start();
      await Future.wait([
        for (var i = 1; i <= 4; i++)
          client.posts.list(ListPostRequest(page: i)),
      ]);
      return watch.elapsed;
    }

    test('queues requests beyond the limit', () async {
      final limited = await timeFour(
        build(adapter, (b) => b.withMaxConcurrentRequests(2).build()),
      );
      final unlimited = await timeFour(build(adapter, (b) => b.build()));

      expect(limited, greaterThan(const Duration(milliseconds: 290)));
      expect(unlimited, lessThan(const Duration(milliseconds: 290)));
    });

    test('limit 1 serialises, and every request still completes', () async {
      final client = build(
        adapter,
        (b) => b.withMaxConcurrentRequests(1).build(),
      );

      final elapsed = await timeFour(client);

      expect(elapsed, greaterThan(const Duration(milliseconds: 590)));
      expect(adapter.callCount(method: 'GET', path: '/posts'), 4);
    });

    test('rejects a limit below 1', () {
      expect(
        () => BootstrapBuilder().withMaxConcurrentRequests(0),
        throwsArgumentError,
      );
    });
  });
}
