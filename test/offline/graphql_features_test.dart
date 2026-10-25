import 'dart:convert';

import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

const _pageDoc =
    r'query($after: String) { posts(after: $after) { nodes { title } '
    'pageInfo { hasNextPage endCursor } } }';

Map<String, dynamic> _page(List<String> titles, {String? next}) => {
      'data': {
        'posts': {
          'nodes': [
            for (final t in titles) {'title': t},
          ],
          'pageInfo': {'hasNextPage': next != null, 'endCursor': next},
        },
      },
    };

void main() {
  late MockWordpressAdapter adapter;

  setUp(() => adapter = MockWordpressAdapter());

  group('partial data and errors (#100)', () {
    final body = {
      'data': {'a': 1, 'b': null},
      'errors': [
        {
          'message': 'b failed',
          'path': ['b'],
          'locations': [
            {'line': 1, 'column': 7},
          ],
          'extensions': {'code': 'INTERNAL'},
        },
      ],
      'extensions': {'tracing': true},
    };

    test('execute returns data next to errors', () async {
      adapter.reply('POST', 'graphql', MockResponse(body: body));
      final client = makeClient(adapter);

      final response = await client.graphql.execute<int>(
        document: '{ a b }',
        parseData: (d) => d['a'] as int,
      );

      final result =
          (response as WordpressSuccessResponse<GraphQLResult<int>>).data;
      expect(result.data, 1);
      expect(result.isPartial, isTrue);
      expect(result.errors.single.message, 'b failed');
      expect(result.errors.single.path, ['b']);
      expect(result.errors.single.code, 'INTERNAL');
      expect(result.errors.single.locations.single, (line: 1, column: 7));
      expect(result.extensions, {'tracing': true});
    });

    test('query still fails but exposes the errors', () async {
      adapter.reply('POST', 'graphql', MockResponse(body: body));
      final client = makeClient(adapter);

      final response = await client.graphql.query<int>(
        document: '{ a b }',
        parseData: (d) => d['a'] as int,
      );

      expect(response.isFailure, isTrue);
      final errors = response.extra?[GraphQLInterface.errorsKey];
      expect(errors, isA<List<GraphQLError>>());
      expect((errors as List<GraphQLError>).single.message, 'b failed');
    });

    test('a null parse result with errors does not throw', () async {
      adapter.reply(
        'POST',
        'graphql',
        const MockResponse(
          body: {
            'data': null,
            'errors': [
              {'message': 'nope'},
            ],
          },
        ),
      );
      final client = makeClient(adapter);

      final response = await client.graphql.execute<int>(
        document: '{ a }',
        parseData: (d) => d['a'] as int,
      );

      final result =
          (response as WordpressSuccessResponse<GraphQLResult<int>>).data;
      expect(result.data, isNull);
      expect(result.hasErrors, isTrue);
    });
  });

  test('transport errors are failures, not exceptions', () async {
    adapter.reply('POST', 'graphql', MockResponse.connectionError());
    final client = makeClient(adapter);

    final response = await client.graphql.query<int>(
      document: '{ a }',
      parseData: (d) => d['a'] as int,
    );

    expect(response.isFailure, isTrue);
  });

  group('GET queries and mutations (#100)', () {
    test('useGet sends the query in the URL and is cacheable', () async {
      adapter.reply(
        'GET',
        'graphql',
        const MockResponse(
          body: {
            'data': {'ok': true},
          },
        ),
      );
      final client = makeClient(
        adapter,
        middlewares: [CacheMiddleware(cache: MemoryCacheStore())],
      );

      Future<WordpressResponse<bool>> run() => client.graphql.query<bool>(
            document: 'query Q(\$id: Int) { ok }',
            variables: {'id': 3},
            operationName: 'Q',
            useGet: true,
            parseData: (d) => d['ok'] as bool,
          );

      await run();
      final second = await run();

      expect(adapter.callCount(method: 'GET'), 1);
      expect(second.headers['X-Cache'], 'HIT');
      final q = adapter.lastRequest!.uri.queryParameters;
      expect(q['query'], contains('query Q'));
      expect(q['operationName'], 'Q');
      expect(jsonDecode(q['variables']!), {'id': 3});
    });

    test('mutations cannot use GET and queries must not use mutate', () {
      final client = makeClient(adapter);

      expect(
        () => client.graphql.raw(document: 'mutation { x }', useGet: true),
        throwsArgumentError,
      );
      expect(
        () => client.graphql.mutate<int>(
          document: '{ x }',
          parseData: (_) => 1,
        ),
        throwsArgumentError,
      );
    });

    test('a POST query keeps the cache, a mutation clears it', () async {
      adapter
        ..reply(
          'GET',
          '/posts',
          const MockResponse(body: [onePost]),
        )
        ..reply(
          'POST',
          'graphql',
          const MockResponse(
            body: {
              'data': {'ok': true},
            },
          ),
        );
      final client = makeClient(
        adapter,
        middlewares: [CacheMiddleware(cache: MemoryCacheStore())],
      );

      await client.posts.list(ListPostRequest());
      await client.graphql.query<bool>(
        document: '{ ok }',
        parseData: (d) => d['ok'] as bool,
      );
      await client.posts.list(ListPostRequest());
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);

      await client.graphql.mutate<bool>(
        document: 'mutation { ok }',
        parseData: (d) => d['ok'] as bool,
      );
      await client.posts.list(ListPostRequest());
      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });
  });

  group('pagination helper (#100)', () {
    test('queryAll follows endCursor until hasNextPage is false', () async {
      adapter.on('POST', 'graphql', (req) {
        final vars = jsonDecode(req.body as String)['variables'] as Map?;

        return switch (vars?['after']) {
          null => MockResponse(body: _page(['a', 'b'], next: 'c1')),
          'c1' => MockResponse(body: _page(['c'], next: 'c2')),
          _ => MockResponse(body: _page(['d'])),
        };
      });
      final client = makeClient(adapter);

      final response = await client.graphql.queryAll<String>(
        document: _pageDoc,
        connectionPath: ['posts'],
        parseNode: (n) => n['title'] as String,
      );

      expect(
        (response as WordpressSuccessResponse<List<String>>).data,
        ['a', 'b', 'c', 'd'],
      );
      expect(adapter.callCount(method: 'POST'), 3);
    });

    test('maxPages bounds the walk', () async {
      adapter.reply(
        'POST',
        'graphql',
        MockResponse(body: _page(['a'], next: 'again')),
      );
      final client = makeClient(adapter);

      final pages = await client.graphql
          .paginate<String>(
            document: _pageDoc,
            connectionPath: ['posts'],
            parseNode: (n) => n['title'] as String,
            maxPages: 2,
          )
          .toList();

      expect(pages, hasLength(2));
    });

    test('errors on a page end the stream with a failure', () async {
      adapter.reply(
        'POST',
        'graphql',
        const MockResponse(
          body: {
            'data': null,
            'errors': [
              {'message': 'denied'},
            ],
          },
        ),
      );
      final client = makeClient(adapter);

      final pages = await client.graphql
          .paginate<String>(
            document: _pageDoc,
            connectionPath: ['posts'],
            parseNode: (n) => n['title'] as String,
          )
          .toList();

      expect(pages.single.isFailure, isTrue);
    });

    test('reads edges { node } connections', () async {
      adapter.reply(
        'POST',
        'graphql',
        const MockResponse(
          body: {
            'data': {
              'posts': {
                'edges': [
                  {
                    'node': {'title': 'x'},
                  },
                ],
                'pageInfo': {'hasNextPage': false},
              },
            },
          },
        ),
      );
      final client = makeClient(adapter);

      final response = await client.graphql.queryAll<String>(
        document: _pageDoc,
        connectionPath: ['posts'],
        parseNode: (n) => n['title'] as String,
      );

      expect((response as WordpressSuccessResponse<List<String>>).data, ['x']);
    });
  });

  group('persisted queries and batching (#100)', () {
    test('APQ sends a hash first and the document after a miss', () async {
      var calls = 0;
      adapter.on('POST', 'graphql', (req) {
        final body = jsonDecode(req.body as String) as Map<String, dynamic>;
        calls++;
        if (!body.containsKey('query')) {
          return const MockResponse(
            body: {
              'errors': [
                {'message': 'PersistedQueryNotFound'},
              ],
            },
          );
        }

        return const MockResponse(
          body: {
            'data': {'ok': true},
          },
        );
      });
      final client = makeClient(adapter);
      client.graphql.useAutomaticPersistedQueries = true;

      final response = await client.graphql.query<bool>(
        document: '{ ok }',
        parseData: (d) => d['ok'] as bool,
      );

      expect(response.isSuccessful, isTrue);
      expect(calls, 2);
      final first = jsonDecode(adapter.requests.first.body as String) as Map;
      expect(
        (first['extensions'] as Map)['persistedQuery']['sha256Hash'],
        hasLength(64),
      );
    });

    test('batch sends an array and splits the results', () async {
      adapter.reply(
        'POST',
        'graphql',
        const MockResponse(
          body: [
            {
              'data': {'a': 1},
            },
            {
              'data': null,
              'errors': [
                {'message': 'bad'},
              ],
            },
          ],
        ),
      );
      final client = makeClient(adapter);

      final response = await client.graphql.batch([
        GraphQLOperation(
          document: '{ a }',
          parseData: (d) => d['a'],
        ),
        const GraphQLOperation(document: '{ b }'),
      ]);

      final results =
          (response as WordpressSuccessResponse<List<GraphQLResult<Object?>>>)
              .data;
      expect(results[0].data, 1);
      expect(results[1].hasErrors, isTrue);
      expect(jsonDecode(adapter.lastRequest!.body as String), isA<List>());
    });

    test('batch fails clearly when batching is not enabled', () async {
      adapter.reply(
        'POST',
        'graphql',
        const MockResponse(
          body: {
            'data': {'a': 1},
          },
        ),
      );
      final client = makeClient(adapter);

      final response = await client.graphql.batch([
        const GraphQLOperation(document: '{ a }'),
      ]);

      expect(response.isFailure, isTrue);
    });
  });
}
