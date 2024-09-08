import 'package:meta/meta.dart';

import '../helpers.dart';

/// A class that represents a key based on a type [T].
///
/// This class is immutable and can be used as a key in collections
/// where you want to differentiate based on types.
@immutable
class TypeKey<T> {
  /// Returns the runtime type of [T].
  Type get _type => typeOf<T>();

  /// Compares this [TypeKey] with another object for equality.
  ///
  /// Two [TypeKey]s are considered equal if they have the same hash code.
  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// Generates a hash code for this [TypeKey].
  ///
  /// The hash code is based on the hash code of the internal type [_type].
  @override
  int get hashCode {
    return _type.hashCode;
  }

  /// Returns a string representation of this [TypeKey].
  ///
  /// The string includes the type parameter [T].
  @override
  String toString() {
    return 'TypeKey<$_type>';
  }

  /// Returns a debug string representation of this [TypeKey].
  ///
  /// This method currently returns the same string as [toString],
  /// but may provide more detailed information in the future.
  String toDebugString() {
    return 'TypeKey<$_type>';
  }
}
