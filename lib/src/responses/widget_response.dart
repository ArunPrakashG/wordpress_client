import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a Widget (wp/v2/widgets)
///
/// Schema: https://developer.wordpress.org/rest-api/reference/widgets/
@immutable
final class Widget implements ISelfRespresentive {
  const Widget({
    required this.id,
    required this.idBase,
    required this.sidebar,
    this.rendered,
    this.renderedForm,
    this.instance,
    this.self = const {},
  });

  factory Widget.fromJson(Map<String, dynamic> json) => Widget(
        id: castOrElse(json['id'], orElse: () => '')!,
        idBase: castOrElse(json['id_base'], orElse: () => '')!,
        sidebar: castOrElse(json['sidebar'], orElse: () => '')!,
        rendered: castOrElse(json['rendered']),
        renderedForm: castOrElse(json['rendered_form']),
        instance: castOrElse(json['instance']),
        self: json,
      );

  /// Unique identifier for the widget.
  final String id;

  /// The type of the widget. Corresponds to ID in widget-types endpoint.
  final String idBase;

  /// The sidebar the widget belongs to.
  final String sidebar;

  /// HTML representation of the widget.
  final String? rendered;

  /// HTML representation of the widget admin form.
  final String? renderedForm;

  /// Instance settings of the widget, if supported.
  final Map<String, dynamic>? instance;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'id_base': idBase,
        'sidebar': sidebar,
        'rendered': rendered,
        'rendered_form': renderedForm,
        'instance': instance,
      };

  @override
  bool operator ==(covariant Widget other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.idBase == idBase &&
        other.sidebar == sidebar &&
        other.rendered == rendered &&
        other.renderedForm == renderedForm &&
        eq(other.instance, instance) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      idBase.hashCode ^
      sidebar.hashCode ^
      (rendered?.hashCode ?? 0) ^
      (renderedForm?.hashCode ?? 0) ^
      (instance?.hashCode ?? 0) ^
      self.hashCode;
}
