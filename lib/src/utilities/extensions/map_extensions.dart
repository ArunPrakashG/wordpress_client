import 'dart:convert';

extension MapExtensions<T> on Map<String, T> {
  /// Converts the map to a JSON-encoded string.
  ///
  /// This method uses the `json.encode` function from the `dart:convert` library
  /// to convert the map to a JSON string representation.
  ///
  /// Returns:
  ///   A JSON-encoded string representation of the map.
  String toJsonString() {
    return json.encode(this);
  }

  /// Adds the given [value] to the map if the value is not null.
  ///
  /// This method is useful for conditionally adding key-value pairs to the map
  /// only when the value is not null.
  ///
  /// Parameters:
  ///   [key]: The key to associate with the value in the map.
  ///   [value]: The value to add to the map if it's not null.
  void addIfNotNull(String key, T value) {
    if (value == null) {
      return;
    }

    this[key] = value;
  }

  /// Adds all key-value pairs from [values] to this map, excluding null values.
  ///
  /// This method iterates through the provided map and adds each key-value pair
  /// to this map, skipping any entries where the value is null.
  ///
  /// Parameters:
  ///   [values]: A map containing the key-value pairs to be added.
  ///             If null, this method does nothing.
  void addAllIfNotNull(Map<String, T>? values) {
    if (values == null) {
      return;
    }

    for (final value in values.entries) {
      if (value.value == null) {
        continue;
      }

      this[value.key] = value.value;
    }
  }
}
