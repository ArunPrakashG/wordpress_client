import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a WordPress taxonomy (e.g., category, post_tag).
@immutable
final class Taxonomy implements ISelfRespresentive {
  const Taxonomy({
    required this.slug,
    required this.types,
    required this.restBase,
    required this.self,
    this.name,
    this.hierarchical,
    this.description,
    this.visibility,
    this.labels,
    this.capabilities,
    this.metaBox,
  });

  factory Taxonomy.fromJson(Map<String, dynamic> json) {
    return Taxonomy(
      slug: castOrElse(json['slug'], orElse: () => '')!,
      types: mapIterableWithChecks<String>(
        json['types'],
        (dynamic v) => v as String,
      ),
      restBase: castOrElse(json['rest_base'], orElse: () => '')!,
      name: castOrElse(json['name']),
      hierarchical: castOrElse(json['hierarchical']),
      description: castOrElse(json['description']),
      visibility: castOrElse<Map<String, dynamic>>(json['visibility']),
      labels: castOrElse<Map<String, dynamic>>(json['labels']),
      capabilities: castOrElse<Map<String, dynamic>>(json['capabilities']),
      metaBox: castOrElse<Map<String, dynamic>>(json['meta_box']),
      self: json,
    );
  }

  final String slug;
  final List<String>? types;
  final String restBase;
  final String? name;
  final bool? hierarchical;
  final String? description;
  final Map<String, dynamic>? visibility;
  final Map<String, dynamic>? labels;
  final Map<String, dynamic>? capabilities;
  final Map<String, dynamic>? metaBox;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'slug': slug,
        'types': types,
        'rest_base': restBase,
        'name': name,
        'hierarchical': hierarchical,
        'description': description,
        'visibility': visibility,
        'labels': labels,
        'capabilities': capabilities,
        'meta_box': metaBox,
      };

  @override
  bool operator ==(covariant Taxonomy other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;
    return other.slug == slug &&
        mapEquals(other.types, types) &&
        other.restBase == restBase &&
        other.name == name &&
        other.hierarchical == hierarchical &&
        other.description == description &&
        mapEquals(other.visibility, visibility) &&
        mapEquals(other.labels, labels) &&
        mapEquals(other.capabilities, capabilities) &&
        mapEquals(other.metaBox, metaBox) &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode =>
      slug.hashCode ^
      types.hashCode ^
      restBase.hashCode ^
      name.hashCode ^
      hierarchical.hashCode ^
      description.hashCode ^
      visibility.hashCode ^
      labels.hashCode ^
      capabilities.hashCode ^
      metaBox.hashCode ^
      self.hashCode;
}
