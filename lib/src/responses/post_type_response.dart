import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a WordPress Post Type (e.g., post, page, wp_block).
@immutable
final class PostType implements ISelfRespresentive {
  const PostType({
    required this.slug,
    required this.restBase,
    required this.viewable,
    required this.self,
    this.name,
    this.description,
    this.hierarchical,
    this.taxonomies,
    this.supports,
    this.labels,
    this.capabilities,
    this.hasArchive,
    this.restNamespace,
    this.visibility,
    this.icon,
  });

  factory PostType.fromJson(Map<String, dynamic> json) {
    return PostType(
      slug: castOrElse(json['slug'], orElse: () => '')!,
      restBase: castOrElse(json['rest_base'], orElse: () => '')!,
      viewable: castOrElse(json['viewable'], orElse: () => false)!,
      name: castOrElse(json['name']),
      description: castOrElse(json['description']),
      hierarchical: castOrElse(json['hierarchical']),
      taxonomies: mapIterableWithChecks<String>(
        json['taxonomies'],
        (dynamic v) => v as String,
      ),
      supports: castOrElse<Map<String, dynamic>>(json['supports']),
      labels: castOrElse<Map<String, dynamic>>(json['labels']),
      capabilities: castOrElse<Map<String, dynamic>>(json['capabilities']),
      hasArchive: castOrElse<Object>(json['has_archive']),
      restNamespace: castOrElse(json['rest_namespace']),
      visibility: castOrElse<Map<String, dynamic>>(json['visibility']),
      icon: castOrElse(json['icon']),
      self: json,
    );
  }

  /// Unique slug for the post type (e.g., "post").
  final String slug;

  /// REST base path for this type (e.g., "posts").
  final String restBase;

  /// Human-readable name (e.g., "Posts").
  final String? name;

  /// Description for the post type.
  final String? description;

  /// Whether the type is hierarchical.
  final bool? hierarchical;

  /// Taxonomies associated with this type.
  final List<String>? taxonomies;

  /// Supported features map.
  final Map<String, dynamic>? supports;

  /// Labels associated with the type.
  final Map<String, dynamic>? labels;

  /// Capabilities for the type.
  final Map<String, dynamic>? capabilities;

  /// If the value is a string, the value will be used as the archive slug; if false, the type has no archive.
  /// This can be a boolean or string per the REST API schema.
  final Object? hasArchive;

  /// REST route's namespace for the post type.
  final String? restNamespace;

  /// The visibility settings for the post type.
  final Map<String, dynamic>? visibility;

  /// The icon for the post type.
  final String? icon;

  /// Whether this type is viewable to the current user.
  final bool viewable;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slug': slug,
      'rest_base': restBase,
      'viewable': viewable,
      'name': name,
      'description': description,
      'hierarchical': hierarchical,
      'taxonomies': taxonomies,
      'supports': supports,
      'labels': labels,
      'capabilities': capabilities,
      'has_archive': hasArchive,
      'rest_namespace': restNamespace,
      'visibility': visibility,
      'icon': icon,
    };
  }

  @override
  bool operator ==(covariant PostType other) {
    if (identical(this, other)) return true;

    final mapEquals = const DeepCollectionEquality().equals;

    return other.slug == slug &&
        other.restBase == restBase &&
        other.name == name &&
        other.description == description &&
        other.hierarchical == hierarchical &&
        mapEquals(other.taxonomies, taxonomies) &&
        mapEquals(other.supports, supports) &&
        mapEquals(other.labels, labels) &&
        mapEquals(other.capabilities, capabilities) &&
        other.hasArchive == hasArchive &&
        other.restNamespace == restNamespace &&
        mapEquals(other.visibility, visibility) &&
        other.icon == icon &&
        other.viewable == viewable &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return slug.hashCode ^
        restBase.hashCode ^
        name.hashCode ^
        description.hashCode ^
        hierarchical.hashCode ^
        taxonomies.hashCode ^
        supports.hashCode ^
        labels.hashCode ^
        capabilities.hashCode ^
        hasArchive.hashCode ^
        restNamespace.hashCode ^
        visibility.hashCode ^
        icon.hashCode ^
        viewable.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'PostType(slug: $slug, restBase: $restBase, name: $name, viewable: $viewable)';
  }
}
