import 'package:meta/meta.dart';

import '../helpers.dart';

@immutable
class TypeKey<T> {
  Type get _type => typeOf<T>();

  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  int get hashCode {
    return _type.hashCode;
  }

  @override
  String toString() {
    return 'TypeKey<$_type>';
  }

  String toDebugString() {
    return 'TypeKey<$_type>';
  }
}
