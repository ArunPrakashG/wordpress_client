import 'package:test/test.dart';
import 'package:wordpress_client/src/graphql/introspection/graphql_introspection.dart';

void main() {
  late GraphQLIntrospection introspection;

  setUp(() {
    // Mock response from GraphQL introspection query
    final mockResponse = {
      'data': {
        '__schema': {
          'types': [
            {
              'name': 'Query',
              'kind': 'OBJECT',
              'description': 'Root query type',
              'fields': [
                {
                  'name': 'user',
                  'description': 'Get a user by ID',
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
              'description': 'A user in the system',
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
                {
                  'name': 'email',
                  'description': 'User email',
                  'args': [],
                  'type': {
                    'name': 'String',
                    'kind': 'SCALAR',
                    'ofType': null,
                  },
                  'isDeprecated': true,
                  'deprecationReason': 'Use emails field instead',
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
              'description': 'ID scalar type',
              'fields': null,
              'interfaces': [],
              'enumValues': null,
              'possibleTypes': null,
              'inputFields': null,
            },
            {
              'name': 'String',
              'kind': 'SCALAR',
              'description': 'String scalar type',
              'fields': null,
              'interfaces': [],
              'enumValues': null,
              'possibleTypes': null,
              'inputFields': null,
            },
            {
              'name': 'UserRole',
              'kind': 'ENUM',
              'description': 'User role enumeration',
              'fields': null,
              'interfaces': [],
              'enumValues': [
                {
                  'name': 'ADMIN',
                  'description': 'Administrator',
                  'isDeprecated': false,
                  'deprecationReason': null,
                },
                {
                  'name': 'USER',
                  'description': 'Regular user',
                  'isDeprecated': false,
                  'deprecationReason': null,
                },
                {
                  'name': 'GUEST',
                  'description': 'Guest user',
                  'isDeprecated': true,
                  'deprecationReason': 'Use USER role instead',
                },
              ],
              'possibleTypes': null,
              'inputFields': null,
            },
          ],
          'queryType': {'name': 'Query'},
          'mutationType': null,
          'subscriptionType': null,
          'directives': [
            {
              'name': 'skip',
              'description': 'Skip this field if argument is true',
              'locations': ['FIELD', 'FRAGMENT_SPREAD', 'INLINE_FRAGMENT'],
              'args': [
                {
                  'name': 'if',
                  'description': 'If true, skip this field',
                  'type': {
                    'name': null,
                    'kind': 'NON_NULL',
                    'ofType': {
                      'name': 'Boolean',
                      'kind': 'SCALAR',
                      'ofType': null,
                    },
                  },
                  'defaultValue': null,
                },
              ],
            },
          ],
        },
      },
    };

    introspection = GraphQLIntrospection(
      executeRequest: (body) async => mockResponse,
    );
  });

  group('GraphQL Introspection Module', () {
    test('fetchSchema() returns GraphQLSchema from introspection query',
        () async {
      final schema = await introspection.fetchSchema();

      expect(schema, isNotNull);
      expect(schema.queryType?.name, equals('Query'));
      expect(schema.types, isNotEmpty);
      expect(schema.types.length, greaterThanOrEqualTo(5));
    });

    test('getType() retrieves a specific type by name', () async {
      final schema = await introspection.fetchSchema();
      final userType = await introspection.getType('User', schema: schema);

      expect(userType, isNotNull);
      expect(userType!.name, equals('User'));
      expect(userType.kind, equals('OBJECT'));
      expect(userType.description, equals('A user in the system'));
    });

    test('getType() returns null for non-existent type', () async {
      final schema = await introspection.fetchSchema();
      final nonExistentType = await introspection.getType(
        'NonExistentType',
        schema: schema,
      );

      expect(nonExistentType, isNull);
    });

    test('getFields() retrieves all fields for a type', () async {
      final schema = await introspection.fetchSchema();
      final userFields = await introspection.getFields('User', schema: schema);

      expect(userFields, isNotEmpty);
      expect(userFields.length, equals(3));
      expect(userFields[0].name, equals('id'));
      expect(userFields[1].name, equals('name'));
      expect(userFields[2].name, equals('email'));
    });

    test('fieldExists() checks if a field exists on a type', () async {
      final schema = await introspection.fetchSchema();
      final idFieldExists =
          await introspection.fieldExists('User', 'id', schema: schema);
      final nonExistentFieldExists = await introspection.fieldExists(
        'User',
        'nonExistent',
        schema: schema,
      );

      expect(idFieldExists, isTrue);
      expect(nonExistentFieldExists, isFalse);
    });

    test('getField() retrieves specific field information', () async {
      final schema = await introspection.fetchSchema();
      final emailField =
          await introspection.getField('User', 'email', schema: schema);

      expect(emailField, isNotNull);
      expect(emailField!.name, equals('email'));
      expect(emailField.description, equals('User email'));
      expect(emailField.isDeprecated, isTrue);
      expect(
        emailField.deprecationReason,
        equals('Use emails field instead'),
      );
    });

    test('GraphQLType handles nullable and list types correctly', () async {
      final schema = await introspection.fetchSchema();
      final queryType = await introspection.getType('Query', schema: schema);
      final usersField = queryType?.fields.firstWhere((f) => f.name == 'users');

      expect(usersField, isNotNull);
      expect(usersField!.type.kind, equals('NON_NULL'));
      expect(usersField.type.ofType?.kind, equals('LIST'));
      expect(usersField.type.ofType?.ofType?.name, equals('User'));
      expect(usersField.type.isNullable, isFalse);
      expect(usersField.type.isList, isFalse);
    });

    test('GraphQLType.baseTypeName unwraps nested type wrappers', () async {
      final schema = await introspection.fetchSchema();
      final queryType = await introspection.getType('Query', schema: schema);
      final usersField = queryType?.fields.firstWhere((f) => f.name == 'users');

      expect(usersField, isNotNull);
      expect(usersField!.type.baseTypeName, equals('User'));
    });

    test('GraphQLIntrospectionException is thrown on execution error',
        () async {
      final failingIntrospection = GraphQLIntrospection(
        executeRequest: (body) async => throw Exception('Network error'),
      );

      expect(
        failingIntrospection.fetchSchema,
        throwsA(isA<GraphQLIntrospectionException>()),
      );
    });
  });
}
