import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a classic Nav Menu Item at /wp/v2/menu-items
///
/// Reference: https://developer.wordpress.org/rest-api/reference/nav_menu_items/
@immutable
final class NavMenuItem implements ISelfRespresentive {
  const NavMenuItem({
    required this.id,
    required this.typeLabel,
    required this.type,
    required this.status,
    required this.self,
    this.title,
    this.parent,
    this.attrTitle,
    this.classes = const <String>[],
    this.description,
    this.menuOrder,
    this.object,
    this.objectId,
    this.target,
    this.url,
    this.xfn = const <String>[],
    this.invalid,
    this.menus,
    this.meta,
  });

  factory NavMenuItem.fromJson(Map<String, dynamic> json) {
    return NavMenuItem(
      id: castOrElse(json['id'], orElse: () => 0)!,
      title: castOrElse(
        json['title'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      typeLabel: castOrElse(json['type_label'], orElse: () => '')!,
      type: castOrElse(json['type'], orElse: () => 'custom')!,
      status: getContentStatusFromValue(castOrElse(json['status'])),
      parent: castOrElse(json['parent']),
      attrTitle: castOrElse(json['attr_title']),
      classes: castOrElse<List<String>>(
            json['classes'],
            transformer: (v) => (v as List).map((e) => e.toString()).toList(),
          ) ??
          const <String>[],
      description: castOrElse(json['description']),
      menuOrder: castOrElse(json['menu_order']),
      object: castOrElse(json['object']),
      objectId: castOrElse(json['object_id']),
      target: castOrElse(json['target']),
      url: castOrElse(json['url']),
      xfn: castOrElse<List<String>>(
            json['xfn'],
            transformer: (v) => (v as List).map((e) => e.toString()).toList(),
          ) ??
          const <String>[],
      invalid: castOrElse(json['invalid']),
      menus: castOrElse(json['menus']),
      meta: castOrElse(json['meta']),
      self: json,
    );
  }

  /// Unique identifier for the object.
  final int id;

  /// The title for the object.
  final Content? title;

  /// Type label for this menu item.
  final String typeLabel;

  /// The family of objects represented.
  final String type; // taxonomy | post_type | post_type_archive | custom

  /// A named status for the object.
  final ContentStatus status;

  /// Parent menu item id.
  final int? parent;

  final String? attrTitle;
  final List<String> classes;
  final String? description;
  final int? menuOrder;
  final String? object;
  final int? objectId;
  final String? target; // _blank or ''
  final String? url;
  final List<String> xfn;
  final bool? invalid;
  final int? menus; // taxonomy term id
  final Map<String, dynamic>? meta;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title?.toJson(),
        'type_label': typeLabel,
        'type': type,
        'status': status.name,
        'parent': parent,
        'attr_title': attrTitle,
        'classes': classes,
        'description': description,
        'menu_order': menuOrder,
        'object': object,
        'object_id': objectId,
        'target': target,
        'url': url,
        'xfn': xfn,
        'invalid': invalid,
        'menus': menus,
        'meta': meta,
      };

  @override
  bool operator ==(covariant NavMenuItem other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.typeLabel == typeLabel &&
        other.type == type &&
        other.status == status &&
        other.parent == parent &&
        other.attrTitle == attrTitle &&
        eq(other.classes, classes) &&
        other.description == description &&
        other.menuOrder == menuOrder &&
        other.object == object &&
        other.objectId == objectId &&
        other.target == target &&
        other.url == url &&
        eq(other.xfn, xfn) &&
        other.invalid == invalid &&
        other.menus == menus &&
        eq(other.meta, meta) &&
        eq(other.title?.toJson(), title?.toJson()) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      typeLabel.hashCode ^
      type.hashCode ^
      status.hashCode ^
      (parent?.hashCode ?? 0) ^
      (attrTitle?.hashCode ?? 0) ^
      classes.hashCode ^
      (description?.hashCode ?? 0) ^
      (menuOrder?.hashCode ?? 0) ^
      (object?.hashCode ?? 0) ^
      (objectId?.hashCode ?? 0) ^
      (target?.hashCode ?? 0) ^
      (url?.hashCode ?? 0) ^
      xfn.hashCode ^
      (invalid?.hashCode ?? 0) ^
      (menus?.hashCode ?? 0) ^
      (meta?.hashCode ?? 0) ^
      (title?.hashCode ?? 0) ^
      self.hashCode;
}
