import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() {
  group('RegisteredQuery', () {
    test('creates a query with all properties', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'testQuery',
        document: '{ __typename }',
        parseData: (data) => data,
        operationName: 'TestOp',
        defaultVariables: {'foo': 'bar'},
        requireAuth: true,
      );

      expect(query.name, equals('testQuery'));
      expect(query.document, equals('{ __typename }'));
      expect(query.operationName, equals('TestOp'));
      expect(query.defaultVariables, equals({'foo': 'bar'}));
      expect(query.requireAuth, isTrue);
    });

    test('creates a query with minimal properties', () {
      final query = RegisteredQuery<String>(
        name: 'minimalQuery',
        document: '{ posts { nodes { id } } }',
        parseData: (data) => data.toString(),
      );

      expect(query.name, equals('minimalQuery'));
      expect(query.operationName, isNull);
      expect(query.defaultVariables, isNull);
      expect(query.requireAuth, isFalse);
    });

    test('copyWith creates a modified copy', () {
      final original = RegisteredQuery<Map<String, dynamic>>(
        name: 'original',
        document: '{ __typename }',
        parseData: (data) => data,
        defaultVariables: {'limit': 10},
      );

      final modified = original.copyWith(
        name: 'modified',
        defaultVariables: {'limit': 20},
      );

      expect(modified.name, equals('modified'));
      expect(modified.defaultVariables, equals({'limit': 20}));
      expect(modified.document, equals(original.document));
    });

    test('toString returns descriptive string', () {
      final query = RegisteredQuery<List<String>>(
        name: 'getPosts',
        document: '{ posts { nodes { id } } }',
        parseData: (data) => [],
        operationName: 'GetPosts',
      );

      expect(query.toString(), contains('RegisteredQuery'));
      expect(query.toString(), contains('getPosts'));
      expect(query.toString(), contains('GetPosts'));
    });

    test('parseData function works correctly', () {
      final query = RegisteredQuery<List<String>>(
        name: 'extractTitles',
        document: '{ posts { nodes { title } } }',
        parseData: (data) {
          final nodes = (data['posts']?['nodes'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
          return nodes.map((e) => e['title'] as String).toList();
        },
      );

      final testData = {
        'posts': {
          'nodes': [
            {'title': 'Post 1'},
            {'title': 'Post 2'},
            {'title': 'Post 3'},
          ],
        },
      };

      final result = query.parseData(testData);
      expect(result, equals(['Post 1', 'Post 2', 'Post 3']));
    });
  });

  group('GraphQL Registry (Unit Tests)', () {
    late WordpressClient client;

    setUp(() {
      // Create a client for testing registry operations
      // Note: We won't make actual requests, just test the registry
      client = WordpressClient(
        baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
        bootstrapper: (builder) => builder.build(),
      );
    });

    tearDown(() {
      client.graphql.clearRegistry();
      client.dispose();
    });

    test('register adds a query to the registry', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'testQuery',
        document: '{ __typename }',
        parseData: (data) => data,
      );

      client.graphql.register(query);

      expect(client.graphql.isRegistered('testQuery'), isTrue);
      expect(client.graphql.registeredQueryCount, equals(1));
    });

    test('register throws on duplicate name without allowOverwrite', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'duplicate',
        document: '{ __typename }',
        parseData: (data) => data,
      );

      client.graphql.register(query);

      expect(
        () => client.graphql.register(query),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('register with allowOverwrite replaces existing query', () {
      final original = RegisteredQuery<Map<String, dynamic>>(
        name: 'overwrite',
        document: '{ original }',
        parseData: (data) => data,
      );

      final replacement = RegisteredQuery<Map<String, dynamic>>(
        name: 'overwrite',
        document: '{ replacement }',
        parseData: (data) => data,
      );

      client.graphql.register(original);
      client.graphql.register(replacement, allowOverwrite: true);

      final retrieved =
          client.graphql.getRegistered<Map<String, dynamic>>('overwrite');
      expect(retrieved!.document, equals('{ replacement }'));
    });

    test('registerAll registers multiple queries', () {
      final queries = [
        RegisteredQuery<Map<String, dynamic>>(
          name: 'query1',
          document: '{ query1 }',
          parseData: (data) => data,
        ),
        RegisteredQuery<Map<String, dynamic>>(
          name: 'query2',
          document: '{ query2 }',
          parseData: (data) => data,
        ),
        RegisteredQuery<Map<String, dynamic>>(
          name: 'query3',
          document: '{ query3 }',
          parseData: (data) => data,
        ),
      ];

      client.graphql.registerAll(queries);

      expect(client.graphql.registeredQueryCount, equals(3));
      expect(client.graphql.isRegistered('query1'), isTrue);
      expect(client.graphql.isRegistered('query2'), isTrue);
      expect(client.graphql.isRegistered('query3'), isTrue);
    });

    test('unregister removes a query from the registry', () {
      final query = RegisteredQuery<Map<String, dynamic>>(
        name: 'toRemove',
        document: '{ __typename }',
        parseData: (data) => data,
      );

      client.graphql.register(query);
      expect(client.graphql.isRegistered('toRemove'), isTrue);

      final removed = client.graphql.unregister('toRemove');
      expect(removed, isTrue);
      expect(client.graphql.isRegistered('toRemove'), isFalse);
    });

    test('unregister returns false for non-existent query', () {
      final removed = client.graphql.unregister('nonExistent');
      expect(removed, isFalse);
    });

    test('clearRegistry removes all queries', () {
      client.graphql.registerAll([
        RegisteredQuery<Map<String, dynamic>>(
          name: 'q1',
          document: '{ q1 }',
          parseData: (data) => data,
        ),
        RegisteredQuery<Map<String, dynamic>>(
          name: 'q2',
          document: '{ q2 }',
          parseData: (data) => data,
        ),
      ]);

      expect(client.graphql.registeredQueryCount, equals(2));

      client.graphql.clearRegistry();

      expect(client.graphql.registeredQueryCount, equals(0));
      expect(client.graphql.isRegistered('q1'), isFalse);
      expect(client.graphql.isRegistered('q2'), isFalse);
    });

    test('isRegistered returns correct values', () {
      client.graphql.register(
        RegisteredQuery<Map<String, dynamic>>(
          name: 'exists',
          document: '{ exists }',
          parseData: (data) => data,
        ),
      );

      expect(client.graphql.isRegistered('exists'), isTrue);
      expect(client.graphql.isRegistered('doesNotExist'), isFalse);
    });

    test('registeredQueryNames returns all names', () {
      client.graphql.registerAll([
        RegisteredQuery<Map<String, dynamic>>(
          name: 'alpha',
          document: '{ alpha }',
          parseData: (data) => data,
        ),
        RegisteredQuery<Map<String, dynamic>>(
          name: 'beta',
          document: '{ beta }',
          parseData: (data) => data,
        ),
        RegisteredQuery<Map<String, dynamic>>(
          name: 'gamma',
          document: '{ gamma }',
          parseData: (data) => data,
        ),
      ]);

      final names = client.graphql.registeredQueryNames.toList();
      expect(names, containsAll(['alpha', 'beta', 'gamma']));
      expect(names.length, equals(3));
    });

    test('getRegistered returns the query or null', () {
      final query = RegisteredQuery<List<String>>(
        name: 'getList',
        document: '{ items }',
        parseData: (data) => [],
        defaultVariables: {'limit': 5},
        requireAuth: true,
      );

      client.graphql.register(query);

      final retrieved = client.graphql.getRegistered<List<String>>('getList');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('getList'));
      expect(retrieved.defaultVariables, equals({'limit': 5}));
      expect(retrieved.requireAuth, isTrue);

      final notFound =
          client.graphql.getRegistered<Map<String, dynamic>>('notFound');
      expect(notFound, isNull);
    });

    test('executeRegistered throws for unregistered query', () async {
      expect(
        () => client.graphql
            .executeRegistered<Map<String, dynamic>>('notRegistered'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('registry maintains type safety with different query types', () {
      // Register queries with different return types
      final stringQuery = RegisteredQuery<String>(
        name: 'stringQuery',
        document: '{ str }',
        parseData: (data) => data.toString(),
      );

      final listQuery = RegisteredQuery<List<int>>(
        name: 'listQuery',
        document: '{ list }',
        parseData: (data) => [1, 2, 3],
      );

      final mapQuery = RegisteredQuery<Map<String, dynamic>>(
        name: 'mapQuery',
        document: '{ map }',
        parseData: (data) => data,
      );

      client.graphql.registerAll([stringQuery, listQuery, mapQuery]);

      expect(client.graphql.registeredQueryCount, equals(3));

      // Retrieve and verify types
      final retrievedString =
          client.graphql.getRegistered<String>('stringQuery');
      final retrievedList =
          client.graphql.getRegistered<List<int>>('listQuery');
      final retrievedMap =
          client.graphql.getRegistered<Map<String, dynamic>>('mapQuery');

      expect(retrievedString, isNotNull);
      expect(retrievedList, isNotNull);
      expect(retrievedMap, isNotNull);
    });
  });
}
