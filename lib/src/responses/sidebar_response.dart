import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a Sidebar (wp/v2/sidebars)
///
/// Schema: https://developer.wordpress.org/rest-api/reference/sidebars/
@immutable
final class Sidebar implements ISelfRespresentive {
  const Sidebar({
    required this.id,
    required this.name,
    required this.description,
    required this.className,
    required this.beforeWidget,
    required this.afterWidget,
    required this.beforeTitle,
    required this.afterTitle,
    required this.status,
    this.widgets = const <String>[],
    this.self = const {},
  });

  factory Sidebar.fromJson(Map<String, dynamic> json) => Sidebar(
        id: castOrElse(json['id'], orElse: () => '')!,
        name: castOrElse(json['name'], orElse: () => '')!,
        description: castOrElse(json['description'], orElse: () => '')!,
        className: castOrElse(json['class'], orElse: () => '')!,
        beforeWidget: castOrElse(json['before_widget'], orElse: () => '')!,
        afterWidget: castOrElse(json['after_widget'], orElse: () => '')!,
        beforeTitle: castOrElse(json['before_title'], orElse: () => '')!,
        afterTitle: castOrElse(json['after_title'], orElse: () => '')!,
        status: castOrElse(json['status'], orElse: () => 'inactive')!,
        widgets: castOrElse<List<String>>(
              json['widgets'],
              transformer: (v) => (v as List)
                  .map(
                    (e) => e is Map<String, dynamic>
                        ? e['id']?.toString() ?? ''
                        : e.toString(),
                  )
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ) ??
            const <String>[],
        self: json,
      );

  /// ID of sidebar.
  final String id;
  final String name;
  final String description;
  final String className;
  final String beforeWidget;
  final String afterWidget;
  final String beforeTitle;
  final String afterTitle;
  final String status; // active | inactive
  final List<String> widgets;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'class': className,
        'before_widget': beforeWidget,
        'after_widget': afterWidget,
        'before_title': beforeTitle,
        'after_title': afterTitle,
        'status': status,
        'widgets': widgets,
      };

  @override
  bool operator ==(covariant Sidebar other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.className == className &&
        other.beforeWidget == beforeWidget &&
        other.afterWidget == afterWidget &&
        other.beforeTitle == beforeTitle &&
        other.afterTitle == afterTitle &&
        other.status == status &&
        eq(other.widgets, widgets) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      className.hashCode ^
      beforeWidget.hashCode ^
      afterWidget.hashCode ^
      beforeTitle.hashCode ^
      afterTitle.hashCode ^
      status.hashCode ^
      widgets.hashCode ^
      self.hashCode;
}
