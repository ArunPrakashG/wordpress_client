import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a Widget Type (wp/v2/widget-types)
///
/// Schema: https://developer.wordpress.org/rest-api/reference/widget-types/
@immutable
final class WidgetType implements ISelfRespresentive {
  const WidgetType({
    required this.id,
    required this.name,
    required this.description,
    required this.isMulti,
    required this.classname,
    this.self = const {},
  });

  factory WidgetType.fromJson(Map<String, dynamic> json) => WidgetType(
        id: castOrElse(json['id'], orElse: () => '')!,
        name: castOrElse(json['name'], orElse: () => '')!,
        description: castOrElse(json['description'], orElse: () => '')!,
        isMulti: castOrElse(json['is_multi'], orElse: () => false)!,
        classname: castOrElse(json['classname'], orElse: () => '')!,
        self: json,
      );

  /// Unique slug identifying the widget type.
  final String id;

  /// Human-readable name identifying the widget type.
  final String name;

  /// Description of the widget.
  final String description;

  /// Whether the widget supports multiple instances.
  final bool isMulti;

  /// Class name of the widget type.
  final String classname;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'is_multi': isMulti,
        'classname': classname,
      };

  @override
  bool operator ==(covariant WidgetType other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.isMulti == isMulti &&
        other.classname == classname &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      isMulti.hashCode ^
      classname.hashCode ^
      self.hashCode;
}
