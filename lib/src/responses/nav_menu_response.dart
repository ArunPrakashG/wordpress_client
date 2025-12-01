import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a classic Navigation Menu (nav_menu taxonomy) at /wp/v2/menus
///
/// Reference: https://developer.wordpress.org/rest-api/reference/nav_menus/
@immutable
final class NavMenu implements ISelfRespresentive {
  const NavMenu({
    required this.id,
    required this.name,
    required this.slug,
    required this.self,
    this.description,
    this.meta,
    this.locations = const <String>[],
    this.autoAdd,
  });

  factory NavMenu.fromJson(Map<String, dynamic> json) {
    return NavMenu(
      id: castOrElse(json['id'], orElse: () => 0)!,
      name: castOrElse(json['name'], orElse: () => '')!,
      slug: castOrElse(json['slug'], orElse: () => '')!,
      description: castOrElse(json['description']),
      meta: castOrElse(json['meta']),
      locations: castOrElse<List<String>>(
            json['locations'],
            transformer: (v) =>
                (v as List).map((e) => e.toString()).toList(growable: false),
          ) ??
          const <String>[],
      autoAdd: castOrElse(json['auto_add']),
      self: json,
    );
  }

  /// Unique identifier for the menu (term ID).
  final int id;

  /// HTML title for the menu.
  final String name;

  /// An alphanumeric identifier for the menu unique to its type.
  final String slug;

  /// HTML description of the menu.
  final String? description;

  /// Meta fields (if any).
  final Map<String, dynamic>? meta;

  /// The locations assigned to the menu.
  final List<String> locations;

  /// Whether to automatically add top level pages to this menu.
  final bool? autoAdd;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'meta': meta,
        'locations': locations,
        'auto_add': autoAdd,
      };

  @override
  bool operator ==(covariant NavMenu other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.description == description &&
        eq(other.meta, meta) &&
        eq(other.locations, locations) &&
        other.autoAdd == autoAdd &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      slug.hashCode ^
      (description?.hashCode ?? 0) ^
      (meta?.hashCode ?? 0) ^
      locations.hashCode ^
      (autoAdd?.hashCode ?? 0) ^
      self.hashCode;
}
