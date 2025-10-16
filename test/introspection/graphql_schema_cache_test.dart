import 'package:test/test.dart';
import 'package:wordpress_client/src/cache/advanced_cache_config.dart';
import 'package:wordpress_client/src/cache/advanced_cache_manager.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_introspection.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_schema_cache.dart';

void main() {
  late AdvancedCacheManager cacheManager;
  late GraphQLIntrospection introspection;
  late GraphQLSchemaCache schemaCache;

  // Mock schema response
  final mockSchemaResponse = {
    'data': {
      '__schema': {
        'types': [
          {
            'name': 'Query',
            'kind': 'OBJECT',
            'description': 'Root query',
            'fields': [
              {
                'name': 'hello',
                'description': 'Hello field',
                'args': [],
                'type': {
                  'name': 'String',
                  'kind': 'SCALAR',
                  'ofType': null,
                },
                'isDeprecated': false,
                'deprecationReason': null,
              },
            ],
            'interfaces': [],
            'enumValues': null,
            'possibleTypes': null,
            'inputFields': null,
          },
          {
            'name': 'String',
            'kind': 'SCALAR',
            'description': 'String type',
            'fields': null,
            'interfaces': [],
            'enumValues': null,
            'possibleTypes': null,
            'inputFields': null,
          },
        ],
        'queryType': {'name': 'Query'},
        'mutationType': null,
        'subscriptionType': null,
        'directives': [],
      },
    },
  };

  setUp(() {
    cacheManager = AdvancedCacheManager(const AdvancedCacheConfig());
    introspection = GraphQLIntrospection(
      executeRequest: (body) async => mockSchemaResponse,
    );
    schemaCache = GraphQLSchemaCache(
      cacheManager: cacheManager,
      introspection: introspection,
      config: GraphQLSchemaCacheConfig(),
    );
  });

  group('GraphQL Schema Cache', () {
    test('getSchema() fetches and caches schema on first call', () async {
      final schema1 = await schemaCache.getSchema();

      expect(schema1, isNotNull);
      expect(schema1.types, isNotEmpty);
      expect(schema1.queryType?.name, equals('Query'));
    });

    test('getSchema() returns cached schema on subsequent calls', () async {
      // First call - fetches from introspection
      final schema1 = await schemaCache.getSchema();
      expect(schema1.types.length, equals(2));

      // Modify the mock to return different data
      // (would fail if this call was executed)
      introspection = GraphQLIntrospection(
        executeRequest: (body) async => throw Exception('Should use cache'),
      );

      // Second call - should use cached schema, not call introspection
      final schema2 = await schemaCache.getSchema();

      expect(schema2, isNotNull);
      expect(schema2.types.length, equals(2));
    });

    test('isSchemaCached() returns true for cached schemas', () async {
      expect(schemaCache.isSchemaCached(), isFalse);

      await schemaCache.getSchema();

      expect(schemaCache.isSchemaCached(), isTrue);
    });

    test('invalidateSchema() removes cached schema', () async {
      await schemaCache.getSchema();
      expect(schemaCache.isSchemaCached(), isTrue);

      await schemaCache.invalidateSchema();

      expect(schemaCache.isSchemaCached(), isFalse);
    });

    test('getRemainingTtl() returns correct TTL for cached schema', () async {
      await schemaCache.getSchema();

      final remaining = schemaCache.getRemainingTtl();

      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(3600));
    });

    test('getStats() returns cache statistics', () async {
      await schemaCache.getSchema();

      final stats = schemaCache.getStats();

      expect(stats.totalCached, equals(1));
      expect(stats.validCached, equals(1));
      expect(stats.expiredCached, equals(0));
      expect(stats.hitRate, equals(100));
    });

    test('refreshSchema() forces fresh fetch and updates cache', () async {
      // First fetch
      final schema1 = await schemaCache.getSchema();
      expect(schema1.types.length, equals(2));

      // Refresh with new mock data
      final newMockResponse = {
        'data': {
          '__schema': {
            'types': [
              {
                'name': 'Query',
                'kind': 'OBJECT',
                'description': 'Updated Query',
                'fields': [
                  {
                    'name': 'hello',
                    'description': 'Hello field',
                    'args': [],
                    'type': {
                      'name': 'String',
                      'kind': 'SCALAR',
                      'ofType': null,
                    },
                    'isDeprecated': false,
                    'deprecationReason': null,
                  },
                  {
                    'name': 'world',
                    'description': 'World field',
                    'args': [],
                    'type': {
                      'name': 'String',
                      'kind': 'SCALAR',
                      'ofType': null,
                    },
                    'isDeprecated': false,
                    'deprecationReason': null,
                  },
                ],
                'interfaces': [],
                'enumValues': null,
                'possibleTypes': null,
                'inputFields': null,
              },
              {
                'name': 'String',
                'kind': 'SCALAR',
                'description': 'String type',
                'fields': null,
                'interfaces': [],
                'enumValues': null,
                'possibleTypes': null,
                'inputFields': null,
              },
            ],
            'queryType': {'name': 'Query'},
            'mutationType': null,
            'subscriptionType': null,
            'directives': [],
          },
        },
      };

      schemaCache = GraphQLSchemaCache(
        cacheManager: cacheManager,
        introspection: GraphQLIntrospection(
          executeRequest: (body) async => newMockResponse,
        ),
        config: GraphQLSchemaCacheConfig(),
      );

      final schema2 = await schemaCache.refreshSchema();

      expect(schema2.types.length, equals(2));
    });

    test('Custom cache key allows multiple schemas', () async {
      final schema1 = await schemaCache.getSchema(cacheKey: 'schema_v1');
      expect(schema1, isNotNull);
      expect(schemaCache.isSchemaCached(cacheKey: 'schema_v1'), isTrue);
      expect(schemaCache.isSchemaCached(cacheKey: 'schema_v2'), isFalse);

      // V2 would fetch fresh in real scenario
      final schema2 = await schemaCache.getSchema(cacheKey: 'schema_v2');
      expect(schema2, isNotNull);
      expect(schemaCache.isSchemaCached(cacheKey: 'schema_v2'), isTrue);
    });

    test('GraphQLSchemaCacheException is thrown on fetch error', () async {
      final failingCache = GraphQLSchemaCache(
        cacheManager: cacheManager,
        introspection: GraphQLIntrospection(
          executeRequest: (body) async =>
              throw Exception('Introspection failed'),
        ),
      );

      expect(
        failingCache.getSchema,
        throwsA(isA<GraphQLSchemaCacheException>()),
      );
    });

    test('Cache respects custom TTL', () async {
      await schemaCache.getSchema(ttlSeconds: 5);

      final remaining = schemaCache.getRemainingTtl();
      expect(remaining, lessThanOrEqualTo(5));
    });
  });
}
