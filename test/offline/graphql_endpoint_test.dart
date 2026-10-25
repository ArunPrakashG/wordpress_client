import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply(
        'POST',
        'graphql',
        const MockResponse(
          body: {
            'data': {'ok': true},
          },
        ),
      );
  });

  Future<WordpressResponse<bool>> run(WordpressClient client) {
    return client.graphql.query<bool>(
      document: '{ ok }',
      parseData: (data) => data['ok'] as bool,
    );
  }

  test('derives the endpoint from the base URL', () async {
    final response = await run(makeClient(adapter));

    expect(response, isA<WordpressSuccessResponse<bool>>());
    expect(adapter.lastRequest!.uri.toString(), 'https://example.com/graphql');
  });

  test('preserves a site subdirectory', () async {
    final client = makeClient(
      adapter,
      baseUrl: Uri.parse('https://example.com/blog/wp-json/wp/v2'),
    );
    await run(client);

    expect(
      adapter.lastRequest!.uri.toString(),
      'https://example.com/blog/graphql',
    );
  });

  test('follows reconfigure(baseUri:)', () async {
    final client = makeClient(adapter);
    await run(client);

    client.reconfigure(
      baseUri: Uri.parse('https://other.example/wp-json/wp/v2'),
    );
    await run(client);

    expect(adapter.requests.map((r) => r.uri.toString()), [
      'https://example.com/graphql',
      'https://other.example/graphql',
    ]);
  });

  test('a custom endpoint path survives reconfigure and stays on-origin',
      () async {
    final client = makeClient(adapter);
    client.graphql.setEndpointPath('/api/graphql');
    adapter.reply(
      'POST',
      'api/graphql',
      const MockResponse(
        body: {
          'data': {'ok': true},
        },
      ),
    );

    await run(client);
    client.reconfigure(
      baseUri: Uri.parse('https://other.example/wp-json/wp/v2'),
    );
    await run(client);

    expect(adapter.requests.map((r) => r.uri.toString()), [
      'https://example.com/api/graphql',
      'https://other.example/api/graphql',
    ]);
  });
}
