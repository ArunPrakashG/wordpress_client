import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply('GET', '/posts', const MockResponse(body: [onePost]));
  });

  group('wire headers (#85)', () {
    test('internal metadata is not sent to the server', () async {
      final client = makeClient(adapter);
      await client.posts.list(ListPostRequest());

      final sent =
          adapter.lastRequest!.headers.keys.map((k) => k.toLowerCase());
      expect(sent, isNot(contains('method')));
      expect(sent, isNot(contains('request-url')));
      expect(sent, isNot(contains('request-query')));
    });

    test('middlewares can still read the request metadata', () async {
      WordpressRequest? seen;
      final client = makeClient(
        adapter,
        middlewares: [
          DelegatedMiddleware(
            onRequestDelegate: (r) async => r,
            onResponseDelegate: (r) async => r,
            onExecuteDelegate: (r) async {
              seen = r;
              return MiddlewareRawResponse.defaultInstance();
            },
          ),
        ],
      );
      await client.posts.list(ListPostRequest());

      expect(seen!.extra[WordpressRequest.metaMethod], 'get');
      expect(
        seen!.extra[WordpressRequest.metaUrl],
        'https://example.com/wp-json/wp/v2/posts',
      );
      expect(seen!.extra[WordpressRequest.metaQuery], contains('per_page=10'));
    });
  });

  group('duration (#86)', () {
    test('covers the whole network round trip', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(
          body: [onePost],
          delay: Duration(milliseconds: 80),
        ),
      );
      final client = makeClient(adapter);
      final response = await client.posts.list(ListPostRequest());

      expect(
        response.duration,
        greaterThanOrEqualTo(const Duration(milliseconds: 70)),
      );
    });
  });

  group('origin lock (#87)', () {
    test('absolute URL on the same origin is used verbatim', () async {
      adapter.reply('GET', '/graphql', const MockResponse(body: {'ok': true}));
      final client = makeClient(adapter);
      final raw = await client.raw(
        WordpressRequest(
          url: RequestUrl.absolute(Uri.parse('https://example.com/graphql')),
          method: HttpMethod.get,
        ),
      );

      expect(raw.code, 200);
      expect(
        adapter.lastRequest!.uri.toString(),
        'https://example.com/graphql',
      );
    });

    for (final other in [
      'https://evil.test/graphql',
      'http://example.com/graphql',
      'https://example.com:8443/graphql',
    ]) {
      test('rejects $other without touching the network', () async {
        final client = makeClient(adapter);
        final raw = await client.raw(
          WordpressRequest(
            url: RequestUrl.absolute(Uri.parse(other)),
            method: HttpMethod.get,
          ),
        );

        expect(raw.errorType, RequestErrorType.originMismatch);
        expect(adapter.requests, isEmpty);
      });
    }
  });

  group('list decoding (#88)', () {
    test('a 200 with a non-array body becomes a failure, not a throw',
        () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(body: '<html>PHP Notice</html>'),
      );
      final client = makeClient(adapter);
      final response = await client.posts.list(ListPostRequest());

      expect(response, isA<WordpressFailureResponse<List<Post>>>());
    });

    test('a 200 with an object body becomes a failure', () async {
      adapter.reply('GET', '/posts', const MockResponse(body: {'a': 1}));
      final client = makeClient(adapter);
      final response = await client.posts.list(ListPostRequest());

      expect(response, isA<WordpressFailureResponse<List<Post>>>());
    });
  });
}
