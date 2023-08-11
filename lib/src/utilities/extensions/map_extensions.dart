import 'dart:convert';

extension MapExtensions<T> on Map<String, T> {
  String toJsonString() {
    return json.encode(this);
  }

  /// Adds the given [value] to the map if the value is not null.
  void addIfNotNull(String key, T value) {
    if (value == null) {
      return;
    }

    this[key] = value;
  }
}
