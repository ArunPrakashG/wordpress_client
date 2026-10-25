import 'package:meta/meta.dart';

/// One entry of the `errors` array of a GraphQL response.
///
/// See https://spec.graphql.org/October2021/#sec-Errors
@immutable
final class GraphQLError {
  const GraphQLError({
    required this.message,
    this.locations = const [],
    this.path = const [],
    this.extensions,
  });

  factory GraphQLError.fromJson(Map<String, dynamic> json) {
    final locations = json['locations'];
    final path = json['path'];
    final extensions = json['extensions'];

    return GraphQLError(
      message: json['message']?.toString() ?? '',
      locations: locations is List
          ? locations
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (l) => (
                  line: (l['line'] as num?)?.toInt() ?? 0,
                  column: (l['column'] as num?)?.toInt() ?? 0,
                ),
              )
              .toList()
          : const [],
      path:
          path is List ? List<Object>.from(path.whereType<Object>()) : const [],
      extensions: extensions is Map<String, dynamic> ? extensions : null,
    );
  }

  /// Human readable description of the error.
  final String message;

  /// Positions in the query document the error refers to.
  final List<({int line, int column})> locations;

  /// Response path (field names and list indexes) of the failing field.
  final List<Object> path;

  /// Server specific details such as an error `code`.
  final Map<String, dynamic>? extensions;

  /// `extensions.code`, if the server set one.
  String? get code => extensions?['code']?.toString();

  @override
  String toString() => 'GraphQLError($message)';
}

/// The complete outcome of a GraphQL operation: data **and** errors.
///
/// GraphQL allows a response to carry both, for example when one field fails
/// but the rest resolve. `GraphQLInterface.query` treats any error as a
/// failure; `GraphQLInterface.execute` returns this so you can use the
/// partial [data].
@immutable
final class GraphQLResult<T> {
  const GraphQLResult({
    this.data,
    this.errors = const [],
    this.extensions,
  });

  /// The parsed `data`, or null when the server returned none.
  final T? data;

  /// Errors reported by the server, empty when there were none.
  final List<GraphQLError> errors;

  /// The response level `extensions` object (tracing, cache hints, ...).
  final Map<String, dynamic>? extensions;

  /// Whether the server reported any error.
  bool get hasErrors => errors.isNotEmpty;

  /// Whether some data came back alongside errors.
  bool get isPartial => hasErrors && data != null;
}

/// One operation of a batched request. See `GraphQLInterface.batch`.
@immutable
final class GraphQLOperation {
  const GraphQLOperation({
    required this.document,
    this.variables,
    this.operationName,
    this.parseData,
  });

  final String document;
  final Map<String, dynamic>? variables;
  final String? operationName;

  /// Converts this operation's `data`; the raw map is used when null.
  final Object? Function(Map<String, dynamic> data)? parseData;
}
