import 'package:test/test.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_introspection.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_query_builder.dart';

void main() {
  late GraphQLSchema schema;
  late GraphQLTypeInfo typeInfo;

  setUp(() {
    // Create a test schema
    final mockResponse = {
      'data': {
        '__schema': {
          'types': [
            {
              'name': 'Query',
              'kind': 'OBJECT',
              'description': 'Root query',
              'fields': [
                {
                  'name': 'user',
                  'description': 'Get user by ID',
                  'args': [
                    {
                      'name': 'id',
                      'description': 'User ID',
                      'type': {
                        'name': null,
                        'kind': 'NON_NULL',
                        'ofType': {
                          'name': 'ID',
                          'kind': 'SCALAR',
                          'ofType': null,
                        },
                      },
                      'defaultValue': null,
                    },
                  ],
                  'type': {
                    'name': 'User',
                    'kind': 'OBJECT',
                    'ofType': null,
                  },
                  'isDeprecated': false,
                  'deprecationReason': null,
                },
                {
                  'name': 'users',
                  'description': 'Get all users',
                  'args': [],
                  'type': {
                    'name': null,
                    'kind': 'NON_NULL',
                    'ofType': {
                      'name': null,
                      'kind': 'LIST',
                      'ofType': {
                        'name': 'User',
                        'kind': 'OBJECT',
                        'ofType': null,
                      },
                    },
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
              'name': 'User',
              'kind': 'OBJECT',
              'description': 'A user',
              'fields': [
                {
                  'name': 'id',
                  'description': 'User ID',
                  'args': [],
                  'type': {
                    'name': null,
                    'kind': 'NON_NULL',
                    'ofType': {
                      'name': 'ID',
                      'kind': 'SCALAR',
                      'ofType': null,
                    },
                  },
                  'isDeprecated': false,
                  'deprecationReason': null,
                },
                {
                  'name': 'name',
                  'description': 'User name',
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
              'name': 'ID',
              'kind': 'SCALAR',
              'description': 'ID type',
              'fields': null,
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

    schema = GraphQLSchema.fromJson(
      (mockResponse['data']! as Map<String, dynamic>)['__schema']
          as Map<String, dynamic>,
    );
    typeInfo = GraphQLTypeInfo(schema: schema);
  });

  group('GraphQL Type Info', () {
    test('getType() returns type by name', () {
      final userType = typeInfo.getType('User');

      expect(userType, isNotNull);
      expect(userType!.name, equals('User'));
      expect(userType.kind, equals('OBJECT'));
    });

    test('getType() returns null for non-existent type', () {
      final unknownType = typeInfo.getType('Unknown');

      expect(unknownType, isNull);
    });

    test('getObjectTypes() returns all object types', () {
      final objectTypes = typeInfo.getObjectTypes();

      expect(objectTypes, isNotEmpty);
      expect(objectTypes.where((t) => t.name == 'Query'), isNotEmpty);
      expect(objectTypes.where((t) => t.name == 'User'), isNotEmpty);
    });

    test('getScalarTypes() returns all scalar types', () {
      final scalarTypes = typeInfo.getScalarTypes();

      expect(scalarTypes, isNotEmpty);
      expect(scalarTypes.where((t) => t.name == 'String'), isNotEmpty);
      expect(scalarTypes.where((t) => t.name == 'ID'), isNotEmpty);
    });

    test('getFields() returns fields for a type', () {
      final userFields = typeInfo.getFields('User');

      expect(userFields, isNotEmpty);
      expect(userFields.length, equals(2));
      expect(userFields[0].name, equals('id'));
      expect(userFields[1].name, equals('name'));
    });

    test('getField() returns specific field information', () {
      final nameField = typeInfo.getField('User', 'name');

      expect(nameField, isNotNull);
      expect(nameField!.name, equals('name'));
      expect(nameField.description, equals('User name'));
    });

    test('fieldExists() checks field existence', () {
      expect(typeInfo.fieldExists('User', 'name'), isTrue);
      expect(typeInfo.fieldExists('User', 'nonexistent'), isFalse);
    });

    test('validateFieldPath() validates nested paths', () {
      expect(typeInfo.validateFieldPath(['Query', 'user']), isTrue);
      expect(typeInfo.validateFieldPath(['Query', 'users']), isTrue);
      expect(typeInfo.validateFieldPath(['Query', 'nonexistent']), isFalse);
    });
  });

  group('GraphQL Query Builder', () {
    test('field() adds a field to the query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo);
      query.field('users');

      expect(query.fieldCount, equals(1));
    });

    test('field() throws exception for non-existent field', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo);

      expect(
        () => query.field('nonexistent'),
        throwsA(isA<GraphQLQueryBuilderException>()),
      );
    });

    test('build() generates valid GraphQL query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)..field('users');

      final queryString = query.build();

      expect(queryString, contains('query'));
      expect(queryString, contains('users'));
    });

    test('field() with arguments generates arguments in query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)
        ..field('user', arguments: {'id': '1'});

      final queryString = query.build();

      expect(queryString, contains('user'));
      expect(queryString, contains('id'));
    });

    test('field() with alias generates aliased query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)
        ..field('user', alias: 'currentUser', arguments: {'id': '1'});

      final queryString = query.build();

      expect(queryString, contains('currentUser'));
    });

    test('multiple fields generate complete query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)
        ..field('user', arguments: {'id': '1'})
        ..field('users');

      expect(query.fieldCount, equals(2));
      expect(query.build(), contains('user'));
      expect(query.build(), contains('users'));
    });

    test('toJson() generates valid query JSON', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)..field('users');

      final json = query.toJson();

      expect(json, containsPair('query', isA<String>()));
      expect(json, containsPair('operationName', 'GeneratedQuery'));
    });

    test('clear() removes all fields', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo)
        ..field('user', arguments: {'id': '1'})
        ..field('users');

      expect(query.fieldCount, equals(2));

      query.clear();

      expect(query.fieldCount, equals(0));
    });

    test('QueryField.toGraphQL() generates field string', () {
      final field = QueryField(
        name: 'user',
        arguments: {'id': '1'},
      );

      final graphql = field.toGraphQL();

      expect(graphql, contains('user'));
      expect(graphql, contains('id'));
    });

    test('QueryField with nested fields generates nested query', () {
      final nestedField = QueryField(name: 'id');
      final parentField = QueryField(
        name: 'user',
        arguments: {'id': '1'},
        nestedFields: [nestedField],
      );

      final graphql = parentField.toGraphQL();

      expect(graphql, contains('user'));
      expect(graphql, contains('id'));
      expect(graphql, contains('{'));
      expect(graphql, contains('}'));
    });

    test('QueryField handles string arguments with escaping', () {
      final field = QueryField(
        name: 'search',
        arguments: {'query': 'hello "world"'},
      );

      final graphql = field.toGraphQL();

      expect(graphql, contains('query'));
    });

    test('build() throws exception for empty query', () {
      final query = GraphQLQueryBuilder(typeInfo: typeInfo);

      expect(
        query.build,
        throwsA(isA<GraphQLQueryBuilderException>()),
      );
    });

    test('GraphQLQueryBuilder throws for invalid root type', () {
      expect(
        () => GraphQLQueryBuilder(
          typeInfo: typeInfo,
          rootType: 'InvalidType',
        ),
        throwsA(isA<GraphQLQueryBuilderException>()),
      );
    });
  });
}
