// ignore_for_file: comment_references

/// An abstract class that provides a self-representation of JSON data.
///
/// This class is designed to handle JSON responses, particularly useful when
/// dealing with dynamic or unknown fields in API responses.
abstract class ISelfRespresentive {
  /// Creates a new instance of [ISelfRespresentive].
  ///
  /// [self] is a required parameter that contains the entire JSON response as a Map.
  const ISelfRespresentive({
    required this.self,
  });

  /// Represents the entire JSON response as a Map<String, dynamic>.
  ///
  /// This field is particularly useful in the following scenarios:
  /// 1. When the API response contains extra fields that are not explicitly modeled.
  /// 2. When you need to access the raw response data without creating a custom model.
  ///
  /// You can access specific fields in two ways:
  /// 1. Using the [getField] method.
  /// 2. Using the subscript operator `[]`. For example: `response['fieldName']`
  ///
  /// Example usage:
  /// ```dart
  /// final response = MyResponse(self: jsonMap);
  /// final specificField = response['fieldName'];
  /// ```
  final Map<String, dynamic> self;
}
