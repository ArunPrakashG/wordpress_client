import 'dart:convert';

extension MapExtensions on Map<String, dynamic> {
  String toJsonString() {
    return json.encode(this);
  }

  /// Adds the given [value] to the map if the value is not null.
  void addIfNotNull(String key, dynamic value) {
    if (value == null) {
      return;
    }

    this[key] = value;
  }
}
