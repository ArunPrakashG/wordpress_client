import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a category in WordPress.
///
/// Categories are a taxonomy in WordPress used to group and organize content.
/// They can be hierarchical, allowing for parent-child relationships between categories.
@immutable
class Category implements ISelfRespresentive {
  /// Creates a new [Category] instance.
  ///
  /// - [id]: Unique identifier for the category.
  /// - [count]: Number of posts in the category.
  /// - [description]: HTML description of the category.
  /// - [link]: URL to the category's archive page.
  /// - [slug]: An alphanumeric identifier for the category unique to its type.
  /// - [taxonomy]: Type of taxonomy. For categories, this is always "category".
  /// - [parent]: The parent category ID, if any.
  /// - [self]: The raw JSON representation of this object.
  /// - [name]: HTML title for the category.
  const Category({
    required this.id,
    required this.count,
    required this.description,
    required this.link,
    required this.slug,
    required this.taxonomy,
    required this.parent,
    required this.self,
    this.name,
    this.meta,
  });

  /// Creates a [Category] instance from a JSON map.
  ///
  /// [json] is the JSON map containing the category data.
  factory Category.fromJson(dynamic json) {
    return Category(
      id: castOrElse(json['id']),
      count: castOrElse(json['count'], orElse: () => 0)!,
      description: castOrElse(json['description']),
      link: castOrElse(json['link']),
      name: castOrElse(json['name']),
      slug: castOrElse(json['slug']),
      taxonomy: castOrElse(json['taxonomy']),
      parent: castOrElse(json['parent']),
      meta: castOrElse(json['meta']),
      self: json as Map<String, dynamic>,
    );
  }

  /// Unique identifier for the category.
  final int id;

  /// Number of posts in the category.
  final int count;

  /// HTML description of the category.
  final String? description;

  /// URL to the category's archive page.
  final String? link;

  /// HTML title for the category.
  final String? name;

  /// An alphanumeric identifier for the category unique to its type.
  final String slug;

  /// Type of taxonomy. For categories, this is always "category".
  final String? taxonomy;

  /// The parent category ID, if any.
  final int? parent;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  /// The raw JSON representation of this object.
  @override
  final Map<String, dynamic> self;

  /// Converts this [Category] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'count': count,
      'description': description,
      'link': link,
      'name': name,
      'slug': slug,
      'taxonomy': taxonomy,
      'parent': parent,
      'meta': meta,
    };
  }

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.count == count &&
        other.description == description &&
        other.link == link &&
        other.name == name &&
        other.slug == slug &&
        other.taxonomy == taxonomy &&
        other.parent == parent &&
        mapEquals(other.meta, meta) &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        count.hashCode ^
        description.hashCode ^
        link.hashCode ^
        name.hashCode ^
        slug.hashCode ^
        taxonomy.hashCode ^
        parent.hashCode ^
        meta.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, parent: $parent, meta: $meta, self: $self)';
  }
}
