import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a Menu Location at /wp/v2/menu-locations
///
/// Reference: https://developer.wordpress.org/rest-api/reference/menu-locations/
@immutable
final class MenuLocation implements ISelfRespresentive {
  const MenuLocation({
    required this.name,
    required this.description,
    required this.menu,
    required this.self,
  });

  factory MenuLocation.fromJson(Map<String, dynamic> json) {
    return MenuLocation(
      name: castOrElse(json['name'], orElse: () => '')!,
      description: castOrElse(json['description'], orElse: () => '')!,
      menu: castOrElse(json['menu'], orElse: () => 0)!,
      self: json,
    );
  }

  /// Name of the menu location.
  final String name;

  /// Description of the menu location.
  final String description;

  /// The ID of the assigned menu.
  final int menu;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'menu': menu,
      };

  @override
  bool operator ==(covariant MenuLocation other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.name == name &&
        other.description == description &&
        other.menu == menu &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      name.hashCode ^ description.hashCode ^ menu.hashCode ^ self.hashCode;
}
