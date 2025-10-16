// GraphQL Introspection - Schema Discovery and Type Information

/// GraphQL Introspection Query Executor
///
/// Executes GraphQL schema introspection queries and parses results
/// to provide runtime access to schema information.
///
/// Usage:
/// ```dart
/// final introspection = GraphQLIntrospection(executor, graphqlEndpoint);
/// final schema = await introspection.fetchSchema();
/// final postType = await introspection.getType('Post');
/// ```

// ============================================================================
// GraphQL Scalar Types
// ============================================================================

/// Represents a GraphQL scalar type (built-in or custom)
class GraphQLScalarType {
  GraphQLScalarType({
    required this.name,
    this.description,
    this.specifiedByUrl,
  });

  factory GraphQLScalarType.fromJson(Map<String, dynamic> json) {
    return GraphQLScalarType(
      name: json['name'] as String,
      description: json['description'] as String?,
      specifiedByUrl: json['specifiedByUrl'] as String?,
    );
  }
  final String name;
  final String? description;
  final String? specifiedByUrl;

  @override
  String toString() => 'GraphQLScalarType($name)';
}

// ============================================================================
// GraphQL Input Values (for function arguments)
// ============================================================================

/// Represents a GraphQL input value (argument or input field)
class GraphQLInputValue {
  GraphQLInputValue({
    required this.name,
    required this.type,
    this.description,
    this.defaultValue,
  });

  factory GraphQLInputValue.fromJson(Map<String, dynamic> json) {
    return GraphQLInputValue(
      name: json['name'] as String,
      description: json['description'] as String?,
      type: GraphQLType.fromJson(json['type'] as Map<String, dynamic>),
      defaultValue: json['defaultValue'] as String?,
    );
  }
  final String name;
  final String? description;
  final GraphQLType type;
  final String? defaultValue;

  @override
  String toString() => 'GraphQLInputValue($name: $type = $defaultValue)';
}

// ============================================================================
// GraphQL Enum Values
// ============================================================================

/// Represents a GraphQL enum value
class GraphQLEnumValue {
  GraphQLEnumValue({
    required this.name,
    this.description,
    this.isDeprecated = false,
    this.deprecationReason,
  });

  factory GraphQLEnumValue.fromJson(Map<String, dynamic> json) {
    return GraphQLEnumValue(
      name: json['name'] as String,
      description: json['description'] as String?,
      isDeprecated: json['isDeprecated'] as bool? ?? false,
      deprecationReason: json['deprecationReason'] as String?,
    );
  }
  final String name;
  final String? description;
  final bool isDeprecated;
  final String? deprecationReason;

  @override
  String toString() => 'GraphQLEnumValue($name)';
}

// ============================================================================
// GraphQL Fields
// ============================================================================

/// Represents a GraphQL field (on object or interface types)
class GraphQLField {
  GraphQLField({
    required this.name,
    required this.type,
    this.description,
    this.args = const [],
    this.isDeprecated = false,
    this.deprecationReason,
  });

  factory GraphQLField.fromJson(Map<String, dynamic> json) {
    final argsList = json['args'] as List<dynamic>? ?? [];
    return GraphQLField(
      name: json['name'] as String,
      description: json['description'] as String?,
      type: GraphQLType.fromJson(json['type'] as Map<String, dynamic>),
      args: argsList
          .map((arg) => GraphQLInputValue.fromJson(arg as Map<String, dynamic>))
          .toList(),
      isDeprecated: json['isDeprecated'] as bool? ?? false,
      deprecationReason: json['deprecationReason'] as String?,
    );
  }
  final String name;
  final String? description;
  final GraphQLType type;
  final List<GraphQLInputValue> args;
  final bool isDeprecated;
  final String? deprecationReason;

  @override
  String toString() => 'GraphQLField($name: $type)';
}

// ============================================================================
// GraphQL Directives
// ============================================================================

/// Represents a GraphQL directive (e.g., @skip, @include)
class GraphQLDirective {
  GraphQLDirective({
    required this.name,
    this.description,
    this.locations = const [],
    this.args = const [],
  });

  factory GraphQLDirective.fromJson(Map<String, dynamic> json) {
    final locationsList = json['locations'] as List<dynamic>? ?? [];
    final argsList = json['args'] as List<dynamic>? ?? [];

    return GraphQLDirective(
      name: json['name'] as String,
      description: json['description'] as String?,
      locations: locationsList.map((loc) => loc as String).toList(),
      args: argsList
          .map((arg) => GraphQLInputValue.fromJson(arg as Map<String, dynamic>))
          .toList(),
    );
  }
  final String name;
  final String? description;
  final List<String> locations;
  final List<GraphQLInputValue> args;

  @override
  String toString() => 'GraphQLDirective($name)';
}

// ============================================================================
// GraphQL Types (Wrapping Types)
// ============================================================================

/// Represents a GraphQL type (object, interface, enum, scalar, etc.)
/// Handles wrapping types (LIST, NON_NULL) recursively
class GraphQLType {
  // For wrapping types (LIST, NON_NULL)

  GraphQLType({
    required this.kind,
    this.name,
    this.description,
    this.fields = const [],
    this.enumValues = const [],
    this.interfaces,
    this.possibleTypes,
    this.ofType,
  });

  /// Create from JSON introspection result
  factory GraphQLType.fromJson(Map<String, dynamic> json) {
    final fieldsList = json['fields'] as List<dynamic>? ?? [];
    final enumValuesList = json['enumValues'] as List<dynamic>? ?? [];
    final interfacesList = json['interfaces'] as List<dynamic>? ?? [];
    final possibleTypesList = json['possibleTypes'] as List<dynamic>? ?? [];
    final ofTypeJson = json['ofType'] as Map<String, dynamic>?;

    return GraphQLType(
      name: json['name'] as String?,
      description: json['description'] as String?,
      kind: json['kind'] as String? ?? 'UNKNOWN',
      fields: fieldsList
          .map((field) => GraphQLField.fromJson(field as Map<String, dynamic>))
          .toList(),
      enumValues: enumValuesList
          .map(
            (value) => GraphQLEnumValue.fromJson(value as Map<String, dynamic>),
          )
          .toList(),
      interfaces: interfacesList.isNotEmpty
          ? interfacesList
              .map(
                (iface) => GraphQLType.fromJson(iface as Map<String, dynamic>),
              )
              .toList()
          : null,
      possibleTypes: possibleTypesList.isNotEmpty
          ? possibleTypesList
              .map((type) => GraphQLType.fromJson(type as Map<String, dynamic>))
              .toList()
          : null,
      ofType: ofTypeJson != null ? GraphQLType.fromJson(ofTypeJson) : null,
    );
  }
  final String? name;
  final String? description;
  final String
      kind; // OBJECT, INTERFACE, ENUM, SCALAR, INPUT_OBJECT, UNION, LIST, NON_NULL
  final List<GraphQLField> fields;
  final List<GraphQLEnumValue> enumValues;
  final List<GraphQLType>? interfaces;
  final List<GraphQLType>? possibleTypes;
  final GraphQLType? ofType;

  /// Check if this type is nullable (not NON_NULL wrapped)
  bool get isNullable => kind != 'NON_NULL';

  /// Check if this is a list type
  bool get isList => kind == 'LIST';

  /// Check if this is a list of non-null items
  bool get isListOfNonNull =>
      kind == 'LIST' && ofType != null && ofType!.kind == 'NON_NULL';

  /// Get the inner type (unwrap LIST/NON_NULL)
  GraphQLType? get innerType => ofType != null
      ? ofType!.kind == 'NON_NULL'
          ? ofType
          : ofType
      : null;

  /// Get the base type name (unwrap all wrappers)
  String? get baseTypeName {
    if (name != null) return name;
    if (ofType != null) return ofType!.baseTypeName;
    return null;
  }

  @override
  String toString() {
    if (name != null) return name!;
    if (kind == 'LIST' && ofType != null) return '[$ofType]';
    if (kind == 'NON_NULL' && ofType != null) return '$ofType!';
    return kind;
  }
}

// ============================================================================
// GraphQL Schema
// ============================================================================

/// Represents a complete GraphQL schema
class GraphQLSchema {
  GraphQLSchema({
    required this.types,
    required this.directives,
    this.queryType,
    this.mutationType,
    this.subscriptionType,
  });

  /// Create from introspection JSON result
  factory GraphQLSchema.fromJson(Map<String, dynamic> json) {
    final typesList = json['types'] as List<dynamic>? ?? [];
    final directivesList = json['directives'] as List<dynamic>? ?? [];

    final types = typesList
        .map((type) => GraphQLType.fromJson(type as Map<String, dynamic>))
        .toList();

    return GraphQLSchema(
      types: types,
      queryType: json['queryType'] != null
          ? GraphQLType.fromJson(
              json['queryType'] as Map<String, dynamic>,
            )
          : null,
      mutationType: json['mutationType'] != null
          ? GraphQLType.fromJson(
              json['mutationType'] as Map<String, dynamic>,
            )
          : null,
      subscriptionType: json['subscriptionType'] != null
          ? GraphQLType.fromJson(
              json['subscriptionType'] as Map<String, dynamic>,
            )
          : null,
      directives: directivesList
          .map(
            (dir) => GraphQLDirective.fromJson(dir as Map<String, dynamic>),
          )
          .toList(),
    );
  }
  final List<GraphQLType> types;
  final GraphQLType? queryType;
  final GraphQLType? mutationType;
  final GraphQLType? subscriptionType;
  final List<GraphQLDirective> directives;

  /// Find a type by name
  GraphQLType? findType(String typeName) {
    try {
      return types.firstWhere((type) => type.name == typeName);
    } catch (e) {
      return null;
    }
  }

  /// Find all types matching predicate
  List<GraphQLType> findTypes(bool Function(GraphQLType) predicate) {
    return types.where(predicate).toList();
  }

  @override
  String toString() => 'GraphQLSchema(${types.length} types)';
}

// ============================================================================
// GraphQL Introspection Executor
// ============================================================================

/// GraphQL Introspection Executor
///
/// Executes GraphQL schema introspection queries
/// Requires a function to make HTTP requests to the GraphQL endpoint
class GraphQLIntrospection {
  GraphQLIntrospection({
    required this.executeRequest,
  });

  /// Function to execute raw HTTP requests to GraphQL endpoint
  /// Should POST JSON body with 'query' field
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> body)
      executeRequest;

  /// Full introspection query (standard GraphQL query)
  static const String _introspectionQuery = '''
query IntrospectionQuery {
  __schema {
    types {
      ...FullType
    }
    queryType { ...TypeRef }
    mutationType { ...TypeRef }
    subscriptionType { ...TypeRef }
    directives {
      name
      description
      locations
      args {
        ...InputValue
      }
    }
  }
}

fragment FullType on __Type {
  kind
  name
  description
  fields(includeDeprecated: true) {
    name
    description
    args {
      ...InputValue
    }
    type { ...TypeRef }
    isDeprecated
    deprecationReason
  }
  inputFields {
    ...InputValue
  }
  interfaces {
    ...TypeRef
  }
  enumValues(includeDeprecated: true) {
    name
    description
    isDeprecated
    deprecationReason
  }
  possibleTypes { ...TypeRef }
}

fragment InputValue on __InputValue {
  name
  description
  type { ...TypeRef }
  defaultValue
}

fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
              }
            }
          }
        }
      }
    }
  }
}
''';

  /// Execute full schema introspection query
  ///
  /// Returns complete schema information from GraphQL endpoint
  /// Throws exception if introspection query fails
  Future<GraphQLSchema> fetchSchema() async {
    try {
      final body = <String, dynamic>{
        'query': _introspectionQuery,
        'operationName': 'IntrospectionQuery',
      };

      final response = await executeRequest(body);

      final data = response['data'];
      if (data == null || data['__schema'] == null) {
        final errors = response['errors'];
        throw GraphQLIntrospectionException(
          'No schema data in introspection response',
          errors: errors,
        );
      }

      return GraphQLSchema.fromJson(data['__schema'] as Map<String, dynamic>);
    } catch (e) {
      if (e is GraphQLIntrospectionException) rethrow;
      throw GraphQLIntrospectionException(
        'Failed to fetch schema: $e',
      );
    }
  }

  /// Get a specific type by name
  Future<GraphQLType?> getType(String typeName,
      {required GraphQLSchema schema}) async {
    return schema.findType(typeName);
  }

  /// Get all types matching predicate
  Future<List<GraphQLType>> getTypes(
    bool Function(GraphQLType) predicate, {
    required GraphQLSchema schema,
  }) async {
    return schema.findTypes(predicate);
  }

  /// Get all fields for a type
  Future<List<GraphQLField>> getFields(
    String typeName, {
    required GraphQLSchema schema,
  }) async {
    final type = schema.findType(typeName);
    return type?.fields ?? [];
  }

  /// Check if field exists on a type
  Future<bool> fieldExists(
    String typeName,
    String fieldName, {
    required GraphQLSchema schema,
  }) async {
    final type = schema.findType(typeName);
    if (type == null) return false;
    return type.fields.any((field) => field.name == fieldName);
  }

  /// Get field information
  Future<GraphQLField?> getField(
    String typeName,
    String fieldName, {
    required GraphQLSchema schema,
  }) async {
    final type = schema.findType(typeName);
    if (type == null) return null;
    try {
      return type.fields.firstWhere((field) => field.name == fieldName);
    } catch (e) {
      return null;
    }
  }

  /// Get all fields of a type (convenience method)
  Future<Map<String, GraphQLField>> getFieldMap(
    String typeName, {
    required GraphQLSchema schema,
  }) async {
    final type = schema.findType(typeName);
    if (type == null) return {};
    return {for (final field in type.fields) field.name: field};
  }
}

// ============================================================================
// Exceptions
// ============================================================================

/// Exception thrown by GraphQL introspection operations
class GraphQLIntrospectionException implements Exception {
  GraphQLIntrospectionException(
    this.message, {
    this.errors,
  });
  final String message;
  final List<dynamic>? errors;

  @override
  String toString() =>
      'GraphQLIntrospectionException: $message${errors != null ? ' | Errors: $errors' : ''}';
}
