import 'package:equatable/equatable.dart';

abstract class ISerializable<T> extends Equatable {
  const ISerializable();

  Map<String, dynamic> toMap();

  T fromMap(Map<String, dynamic> map);
}
