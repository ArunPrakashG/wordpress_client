import 'package:meta/meta.dart';

import 'utilities/helpers.dart';

@immutable
class InterfaceKey<T> {
  const InterfaceKey([this._key = '']);

  Type get _type => typeOf<T>();
  final String? _key;

  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  int get hashCode {
    return _type.hashCode ^ (_key?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'InterfaceKey<$_type>$_key';
  }

  String toDebugString() {
    final tag = _key == null ? '' : ', $_key';
    return 'InterfaceKey<$_type>(${_type.toString()}$tag)';
  }
}
