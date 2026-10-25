import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;
  late List<String> lines;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply(
        'GET',
        '/posts',
        MockResponse.paged([onePost], total: 1, totalPages: 1),
      )
      ..reply(
        'GET',
        '/pages',
        MockResponse.wpError(statusCode: 403, code: 'rest_forbidden'),
      );
    lines = [];
  });

  test('logs one line per response with method, url, status and timing',
      () async {
    final client = makeClient(
      adapter,
      middlewares: [LoggingMiddleware(sink: lines.add)],
    );

    await client.posts.list(ListPostRequest(perPage: 5));

    expect(lines, hasLength(1));
    const url = 'https://example.com/wp-json/wp/v2/posts';
    expect(lines.single, startsWith('GET $url'));
    expect(lines.single, contains('per_page=5'));
    expect(lines.single, contains('-> 200 in '));
  });

  test('logs failures and hides sensitive query values and headers', () async {
    final client = makeClient(
      adapter,
      middlewares: [
        LoggingMiddleware(
          sink: lines.add,
          logRequests: true,
          logHeaders: true,
          logBodies: true,
        ),
      ],
      auth: WordpressAuth.appPassword(user: 'admin', appPassword: 'sekret pw'),
    );

    await client.pages
        .list(ListPageRequest(queryParameters: {'token': 'abc123'}));

    final all = lines.join('\n');
    expect(all, contains('-> 403'));
    expect(all, contains('token=***'));
    expect(all, isNot(contains('abc123')));
    expect(all, isNot(contains('sekret')));
    expect(all, contains('rest_forbidden'));
  });

  test('truncates long bodies', () async {
    adapter.reply('GET', '/media', MockResponse(body: List.filled(400, 'x')));
    final client = makeClient(
      adapter,
      middlewares: [
        LoggingMiddleware(sink: lines.add, logBodies: true, maxBodyLength: 40),
      ],
    );

    await client.media.list(ListMediaRequest());

    expect(lines.single, contains('chars)'));
  });

  test('logs transport failures with the request they belong to', () async {
    adapter.reply('GET', '/posts', MockResponse.connectionError());
    final client = makeClient(
      adapter,
      middlewares: [LoggingMiddleware(sink: lines.add)],
    );

    await client.posts.list(ListPostRequest());

    expect(lines.single, startsWith('GET https://example.com/wp-json'));
    expect(lines.single, contains('-> ERR connectionFailed'));
  });
}
