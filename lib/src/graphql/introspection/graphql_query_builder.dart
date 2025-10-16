import 'graphql_introspection.dart';

/// Provides type information for GraphQL fields and types
/// Used by the query builder for type-safe field validation and suggestions
class GraphQLTypeInfo {
  GraphQLTypeInfo({required this.schema});

  /// The underlying schema
  final GraphQLSchema schema;

  /// Get type information by name
  GraphQLType? getType(String typeName) {
    return schema.findType(typeName);
  }

  /// Get all types in the schema
  List<GraphQLType> getAllTypes() {
    return schema.types;
  }

  /// Get all types matching a predicate
  List<GraphQLType> findTypes(bool Function(GraphQLType) predicate) {
    return schema.findTypes(predicate);
  }

  /// Get all object types
  List<GraphQLType> getObjectTypes() {
    return schema.findTypes((type) => type.kind == 'OBJECT');
  }

  /// Get all interface types
  List<GraphQLType> getInterfaceTypes() {
    return schema.findTypes((type) => type.kind == 'INTERFACE');
  }

  /// Get all enum types
  List<GraphQLType> getEnumTypes() {
    return schema.findTypes((type) => type.kind == 'ENUM');
  }

  /// Get all scalar types
  List<GraphQLType> getScalarTypes() {
    return schema.findTypes((type) => type.kind == 'SCALAR');
  }

  /// Get input types (input objects)
  List<GraphQLType> getInputTypes() {
    return schema.findTypes((type) => type.kind == 'INPUT_OBJECT');
  }

  /// Check if a type is nullable
  bool isNullable(GraphQLType type) {
    return type.isNullable;
  }

  /// Check if a type is a list
  bool isList(GraphQLType type) {
    return type.isList;
  }

  /// Get the base type (unwrap all wrappers)
  String? getBaseTypeName(GraphQLType type) {
    return type.baseTypeName;
  }

  /// Get fields for a type
  List<GraphQLField> getFields(String typeName) {
    final type = schema.findType(typeName);
    return type?.fields ?? [];
  }

  /// Get a specific field from a type
  GraphQLField? getField(String typeName, String fieldName) {
    final type = schema.findType(typeName);
    if (type == null) return null;

    try {
      return type.fields.firstWhere((f) => f.name == fieldName);
    } catch (e) {
      return null;
    }
  }

  /// Check if a field exists on a type
  bool fieldExists(String typeName, String fieldName) {
    return getField(typeName, fieldName) != null;
  }

  /// Get field arguments
  List<GraphQLInputValue> getFieldArgs(String typeName, String fieldName) {
    final field = getField(typeName, fieldName);
    return field?.args ?? [];
  }

  /// Get query type
  GraphQLType? getQueryType() {
    return schema.queryType;
  }

  /// Get mutation type
  GraphQLType? getMutationType() {
    return schema.mutationType;
  }

  /// Get subscription type
  GraphQLType? getSubscriptionType() {
    return schema.subscriptionType;
  }

  /// Validate a type name exists
  bool validateTypeName(String typeName) {
    return schema.findType(typeName) != null;
  }

  /// Validate a field path (e.g., "Query.user.name")
  bool validateFieldPath(List<String> path) {
    if (path.isEmpty) return false;

    var currentTypeName = path.first;
    var currentType = schema.findType(currentTypeName);

    if (currentType == null) return false;

    for (var i = 1; i < path.length; i++) {
      final fieldName = path[i];
      final field = getField(currentTypeName, fieldName);

      if (field == null) return false;

      // Move to next type
      final nextTypeName = field.type.baseTypeName;
      if (nextTypeName == null) return false;

      currentType = schema.findType(nextTypeName);
      if (currentType == null) return false;

      currentTypeName = nextTypeName;
    }

    return true;
  }
}

/// Exception thrown by query builder
class GraphQLQueryBuilderException implements Exception {
  GraphQLQueryBuilderException(
    this.message, {
    this.fieldPath,
    this.cause,
  });

  final String message;
  final List<String>? fieldPath;
  final Exception? cause;

  @override
  String toString() =>
      'GraphQLQueryBuilderException: $message${fieldPath != null ? ' at ${fieldPath!.join('.')}' : ''}${cause != null ? ' | Caused by: $cause' : ''}';
}

/// Represents a single field in a GraphQL query
class QueryField {
  QueryField({
    required this.name,
    this.alias,
    this.arguments = const {},
    this.nestedFields = const [],
    this.fragment,
  });

  /// Field name
  final String name;

  /// Alias for the field (optional)
  final String? alias;

  /// Field arguments as map
  final Map<String, dynamic> arguments;

  /// Nested fields (for object types)
  final List<QueryField> nestedFields;

  /// Field selection fragment (for inline fragments)
  final String? fragment;

  /// Check if this field has nested selections
  bool get hasNestedFields => nestedFields.isNotEmpty;

  /// Convert to GraphQL query string
  String toGraphQL() {
    final buffer = StringBuffer();

    // Add alias if present
    if (alias != null) {
      buffer.write('$alias: ');
    }

    buffer.write(name);

    // Add arguments
    if (arguments.isNotEmpty) {
      buffer.write('(');
      final args = arguments.entries
          .map((e) => '${e.key}: ${_formatArgument(e.value)}')
          .join(', ');
      buffer.write(args);
      buffer.write(')');
    }

    // Add nested fields
    if (hasNestedFields) {
      buffer.write(' { ');
      final nested = nestedFields.map((f) => f.toGraphQL()).join(' ');
      buffer.write(nested);
      buffer.write(' }');
    }

    return buffer.toString();
  }

  String _formatArgument(dynamic value) {
    if (value is String) {
      return '"${value.replaceAll('"', '\\"')}"';
    } else if (value is bool) {
      return value ? 'true' : 'false';
    } else if (value is num) {
      return value.toString();
    } else if (value is List) {
      final items = value.map(_formatArgument).join(', ');
      return '[$items]';
    } else if (value is Map) {
      final items = value.entries
          .map((e) => '${e.key}: ${_formatArgument(e.value)}')
          .join(', ');
      return '{$items}';
    }
    return value.toString();
  }
}

/// Builder for type-safe GraphQL queries
class GraphQLQueryBuilder {
  GraphQLQueryBuilder({
    required this.typeInfo,
    this.rootType = 'Query',
  }) {
    // Validate root type exists
    if (typeInfo.getType(rootType) == null) {
      throw GraphQLQueryBuilderException(
        'Root type "$rootType" does not exist in schema',
      );
    }
  }

  /// Type information provider
  final GraphQLTypeInfo typeInfo;

  /// Root type (Query, Mutation, or Subscription)
  final String rootType;

  /// Selected fields
  final List<QueryField> _fields = [];

  /// Add a field to the query
  GraphQLQueryBuilder field(
    String fieldName, {
    String? alias,
    Map<String, dynamic> arguments = const {},
    List<QueryField> nestedFields = const [],
  }) {
    // Validate field exists on root type
    if (!typeInfo.fieldExists(rootType, fieldName)) {
      throw GraphQLQueryBuilderException(
        'Field "$fieldName" does not exist on type "$rootType"',
        fieldPath: [rootType, fieldName],
      );
    }

    _fields.add(
      QueryField(
        name: fieldName,
        alias: alias,
        arguments: arguments,
        nestedFields: nestedFields,
      ),
    );

    return this;
  }

  /// Add nested fields to the last added field
  GraphQLQueryBuilder withNested(
    List<QueryField> nestedFields,
  ) {
    if (_fields.isEmpty) {
      throw GraphQLQueryBuilderException(
        'Cannot add nested fields - no parent field added',
      );
    }

    final lastField = _fields.removeLast();
    _fields.add(
      QueryField(
        name: lastField.name,
        alias: lastField.alias,
        arguments: lastField.arguments,
        nestedFields: nestedFields,
      ),
    );

    return this;
  }

  /// Build the query string
  String build() {
    if (_fields.isEmpty) {
      throw GraphQLQueryBuilderException('Query has no fields');
    }

    final queryBody = _fields.map((field) => field.toGraphQL()).join(' ');

    return 'query { $queryBody }';
  }

  /// Get the query as JSON (for sending to server)
  Map<String, dynamic> toJson() {
    return {
      'query': build(),
      'operationName': 'GeneratedQuery',
    };
  }

  /// Clear all fields
  void clear() {
    _fields.clear();
  }

  /// Get number of fields
  int get fieldCount => _fields.length;

  /// Get selected fields
  List<QueryField> get fields => List.unmodifiable(_fields);
}

/// Builder for type-safe GraphQL mutations
class GraphQLMutationBuilder {
  GraphQLMutationBuilder({required this.typeInfo}) {
    // Validate Mutation type exists
    if (typeInfo.getMutationType() == null) {
      throw GraphQLQueryBuilderException(
        'Mutation type does not exist in schema',
      );
    }
  }

  /// Type information provider
  final GraphQLTypeInfo typeInfo;

  /// Selected fields
  final List<QueryField> _fields = [];

  /// Add a mutation field
  GraphQLMutationBuilder mutation(
    String fieldName, {
    String? alias,
    Map<String, dynamic> arguments = const {},
    List<QueryField> nestedFields = const [],
  }) {
    final mutationType = typeInfo.getMutationType();
    if (mutationType == null) {
      throw GraphQLQueryBuilderException('Mutation type not available');
    }

    if (!typeInfo.fieldExists(mutationType.name ?? 'Mutation', fieldName)) {
      throw GraphQLQueryBuilderException(
        'Mutation field "$fieldName" does not exist',
      );
    }

    _fields.add(
      QueryField(
        name: fieldName,
        alias: alias,
        arguments: arguments,
        nestedFields: nestedFields,
      ),
    );

    return this;
  }

  /// Build the mutation string
  String build() {
    if (_fields.isEmpty) {
      throw GraphQLQueryBuilderException('Mutation has no fields');
    }

    final mutationBody = _fields.map((field) => field.toGraphQL()).join(' ');

    return 'mutation { $mutationBody }';
  }

  /// Get the mutation as JSON
  Map<String, dynamic> toJson() {
    return {
      'query': build(),
      'operationName': 'GeneratedMutation',
    };
  }

  /// Clear all fields
  void clear() {
    _fields.clear();
  }
}
