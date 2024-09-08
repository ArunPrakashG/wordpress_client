import 'package:meta/meta.dart';

import 'utilities/helpers.dart';

/// A class representing a unique key for an interface of type T.
///
/// This class is used to create a unique identifier for interfaces,
/// combining the type T with an optional string key.
///
/// Example:
/// ```dart
/// final userKey = InterfaceKey<User>('primary');
/// final postKey = InterfaceKey<Post>();
/// ```
@immutable
final class InterfaceKey<T> {
  /// Creates an [InterfaceKey] with an optional string key.
  ///
  /// If no key is provided, an empty string is used as the default.
  ///
  /// Example:
  /// ```dart
  /// final key1 = InterfaceKey<String>('custom');
  /// final key2 = InterfaceKey<int>(); // Uses default empty string
  /// ```
  const InterfaceKey([this._key = '']);

  /// The type of the interface this key represents.
  Type get _type => typeOf<T>();

  /// An optional string to further specify the key.
  final String? _key;

  /// Compares this [InterfaceKey] with another object for equality.
  ///
  /// Two [InterfaceKey]s are considered equal if they have the same hash code.
  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// Generates a hash code for this [InterfaceKey].
  ///
  /// The hash code is a combination of the type's hash code and the optional key's hash code.
  @override
  int get hashCode {
    return _type.hashCode ^ (_key?.hashCode ?? 0);
  }

  /// Returns a string representation of this [InterfaceKey].
  ///
  /// Example:
  /// ```dart
  /// final key = InterfaceKey<User>('admin');
  /// print(key.toString()); // Outputs: InterfaceKey<User>admin
  /// ```
  @override
  String toString() {
    return 'InterfaceKey<$_type>$_key';
  }

  /// Returns a more detailed string representation for debugging purposes.
  ///
  /// Example:
  /// ```dart
  /// final key = InterfaceKey<User>('admin');
  /// print(key.toDebugString()); // Outputs: InterfaceKey<User>(User, admin)
  /// ```
  String toDebugString() {
    final tag = _key == null ? '' : ', $_key';
    return 'InterfaceKey<$_type>($_type$tag)';
  }
}
