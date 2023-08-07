import '../helpers.dart';
import '../self_representive_base.dart';

extension SelfRepresentiveExtensions on ISelfRespresentive {
  /// Returns the value of the key or null if it doesn't exist.
  ///
  /// Casts the returning value to the type of the generic type parameter.
  T? getField<T>(
    String key, {
    T Function()? orElse,
    T? Function(dynamic value)? transformer,
  }) {
    return castOrElse(
      self[key],
      orElse: orElse,
      transformer: transformer,
    );
  }

  /// Checks if the self map contains the key
  bool containsKey(String key) => self.containsKey(key);

  /// Returns the value of the key or null if it doesn't exist.
  dynamic operator [](String key) => self[key];

  @Deprecated('Use "self"')
  Map<String, dynamic> get json => self;
}
