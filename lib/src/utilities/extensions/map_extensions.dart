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
