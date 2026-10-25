import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;

  setUp(() => adapter = MockWordpressAdapter());

  group('WordpressEvents', () {
    test('onError receives the WordPress error body', () async {
      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(
          statusCode: 403,
          code: 'rest_forbidden',
          message: 'No.',
        ),
      );
      final client = makeClient(adapter);
      WordpressError? seen;

      await client.posts.list(
        ListPostRequest(events: WordpressEvents(onError: (e) => seen = e)),
      );

      expect(seen?.code, 'rest_forbidden');
      expect(seen?.status, 403);
    });

    test('onError falls back to a synthetic error for transport failures',
        () async {
      adapter.reply('GET', '/posts', MockResponse.timeout());
      final client = makeClient(adapter);
      WordpressError? seen;

      await client.posts.list(
        ListPostRequest(events: WordpressEvents(onError: (e) => seen = e)),
      );

      expect(seen?.code, RequestErrorType.timeout.name);
    });

    test('onCancel fires when the request is cancelled', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(body: [], delay: Duration(milliseconds: 200)),
      );
      final client = makeClient(adapter);
      final token = CancelToken();
      var cancelled = 0;
      var errors = 0;

      final future = client.posts.list(
        ListPostRequest(
          cancelToken: token,
          events: WordpressEvents(
            onCancel: () => cancelled++,
            onError: (_) => errors++,
          ),
        ),
      );
      token.cancel();
      await future;

      expect(cancelled, 1);
      expect(errors, 0);
    });

    test('nothing fires on success, and a throwing callback is contained',
        () async {
      adapter
        ..reply('GET', '/posts', const MockResponse(body: []))
        ..reply('GET', '/pages', const MockResponse(statusCode: 500));
      final client = makeClient(adapter);
      var errors = 0;

      await client.posts.list(
        ListPostRequest(events: WordpressEvents(onError: (_) => errors++)),
      );
      expect(errors, 0);

      final failed = await client.pages.list(
        ListPageRequest(
          events: WordpressEvents(onError: (_) => throw StateError('boom')),
        ),
      );
      expect(failed.isFailure, isTrue);
    });
  });
}
