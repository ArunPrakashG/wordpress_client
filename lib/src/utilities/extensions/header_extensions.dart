import 'package:dio/dio.dart';

extension HeaderExtension on Headers {
  /// Gets all the headers as a map.
  Map<String, String> getHeaderMap() {
    return map.map<String, String>((key, value) {
      return MapEntry(key, value.join(';'));
    });
  }
}
