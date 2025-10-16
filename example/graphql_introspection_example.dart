/// Example: Using GraphQL Schema Introspection & Query Builder
///
/// This example demonstrates the complete Feature 4 workflow:
/// 1. Fetching GraphQL schema via introspection
/// 2. Caching the schema with TTL
/// 3. Building type-safe queries
/// 4. Executing queries against the GraphQL endpoint

import 'package:wordpress_client/src/cache/advanced_cache_config.dart';
import 'package:wordpress_client/src/cache/advanced_cache_manager.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_introspection.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_query_builder.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_schema_cache.dart';

void main() async {
  // ===== Phase 1: Basic Introspection =====

  // 1. Create an introspection executor with your GraphQL HTTP client
  final introspection = GraphQLIntrospection(
    executeRequest: (body) async {
      // TODO: Replace with your actual HTTP client
      // Example using http package:
      // final response = await http.post(
      //   Uri.parse('https://api.example.com/graphql'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(body),
      // );
      // return jsonDecode(response.body);

      // For demo, returning mock response
      return {
        'data': {
          '__schema': {
            'types': [],
            'queryType': null,
            'mutationType': null,
            'subscriptionType': null,
            'directives': [],
          },
        },
      };
    },
  );

  // 2. Fetch schema from GraphQL endpoint
  print('=== Fetching Schema ===');
  final schema = await introspection.fetchSchema();
  print('Schema types: ${schema.types.length}');
  print('Query type: ${schema.queryType?.name}');

  // ===== Phase 2: Schema Caching =====

  // 3. Create cache manager and schema cache
  final cacheManager = AdvancedCacheManager(const AdvancedCacheConfig());
  final schemaCache = GraphQLSchemaCache(
    cacheManager: cacheManager,
    introspection: introspection,
    config: GraphQLSchemaCacheConfig(),
  );

  print('\n=== Using Schema Cache ===');

  // 4. Get schema with automatic caching
  final cachedSchema = await schemaCache.getSchema();
  print('Cached schema types: ${cachedSchema.types.length}');

  // 5. Check cache status
  final stats = schemaCache.getStats();
  print('Cache stats: $stats');

  // 6. Get remaining TTL
  final remainingTtl = schemaCache.getRemainingTtl();
  print('Remaining TTL: ${remainingTtl}s');

  // ===== Phase 3: Type-Safe Query Builder =====

  print('\n=== Building Type-Safe Queries ===');

  // 7. Create type info provider from schema
  final typeInfo = GraphQLTypeInfo(schema: cachedSchema);

  // 8. Validate types and fields
  final userType = typeInfo.getType('User');
  print('Found User type: ${userType != null}');

  final queryType = typeInfo.getQueryType();
  print('Query type exists: ${queryType != null}');

  // 9. Build a simple query
  try {
    final query = GraphQLQueryBuilder(typeInfo: typeInfo)..field('users');

    print('Generated query:');
    print(query.build());

    final queryJson = query.toJson();
    print('Query as JSON: $queryJson');
  } catch (e) {
    print('Query build error: $e');
  }

  // 10. Build query with arguments and nested fields
  try {
    final nestedField = QueryField(
      name: 'id',
    );

    final nameField = QueryField(
      name: 'name',
    );

    final query = GraphQLQueryBuilder(typeInfo: typeInfo)
      ..field(
        'user',
        arguments: {'id': '123'},
        nestedFields: [nestedField, nameField],
      );

    print('\nGenerated query with nested fields:');
    print(query.build());
  } catch (e) {
    print('Query build error: $e');
  }

  // ===== Complete Workflow Example =====

  print('\n=== Complete Workflow ===');

  // 11. Workflow: Schema validation, caching, and query building
  final workflowSchema = await schemaCache.getSchema();
  final workflowTypeInfo = GraphQLTypeInfo(schema: workflowSchema);

  // Validate a field exists before building query
  if (workflowTypeInfo.fieldExists('Query', 'users')) {
    final safeQuery = GraphQLQueryBuilder(typeInfo: workflowTypeInfo)
      ..field('users');

    print('Safe query generated: ${safeQuery.build()}');
  }

  // ===== Advanced Features =====

  print('\n=== Advanced Features ===');

  // 12. Multiple schema versions with different cache keys
  await schemaCache.getSchema(
    cacheKey: 'schema_v1',
    ttlSeconds: 3600,
  );

  await schemaCache.getSchema(
    cacheKey: 'schema_v2',
    ttlSeconds: 7200,
  );

  print(
      'V1 Schema cached: ${schemaCache.isSchemaCached(cacheKey: 'schema_v1')}');
  print(
      'V2 Schema cached: ${schemaCache.isSchemaCached(cacheKey: 'schema_v2')}');

  // 13. Refresh schema (invalidate and refetch)
  final refreshedSchema = await schemaCache.refreshSchema();
  print('Schema refreshed: ${refreshedSchema.types.length} types');

  // 14. Schema exploration
  final objectTypes = workflowTypeInfo.getObjectTypes();
  final scalarTypes = workflowTypeInfo.getScalarTypes();
  final enumTypes = workflowTypeInfo.getEnumTypes();

  print('Object types: ${objectTypes.length}');
  print('Scalar types: ${scalarTypes.length}');
  print('Enum types: ${enumTypes.length}');

  // 15. Field validation
  final validFieldPath = workflowTypeInfo.validateFieldPath(['Query', 'users']);
  print('Field path Query.users valid: $validFieldPath');

  print('\n=== Feature 4 Complete ===');
}

// Helper function to format query for display
String formatQuery(String query) {
  return query
      .replaceAll('{ ', '{\n  ')
      .replaceAll(' }', '\n}')
      .replaceAll(' query', '\nquery');
}
