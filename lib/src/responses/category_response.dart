import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/self_representive_base.dart';
import 'response_properties/links.dart';

@immutable
class Category implements ISelfRespresentive {
  const Category({
    this.id,
    this.count,
    this.description,
    this.link,
    this.name,
    this.slug,
    this.taxonomy,
    this.parent,
    this.meta,
    this.links,
    required this.self,
  });

  factory Category.fromJson(dynamic json) {
    return Category(
      id: json['id'] as int?,
      count: json['count'] as int?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      taxonomy: json['taxonomy'] as String?,
      parent: json['parent'] as int?,
      meta: json['meta'],
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
      self: json as Map<String, dynamic>,
    );
  }

  final int? id;
  final int? count;
  final String? description;
  final String? link;
  final String? name;
  final String? slug;
  final String? taxonomy;
  final int? parent;
  final dynamic meta;
  final Links? links;

  @override
  final Map<String, dynamic> self;

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
      '_links': links?.toJson(),
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
        other.meta == meta &&
        other.links == links &&
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
        links.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, parent: $parent, meta: $meta, links: $links, self: $self)';
  }
}
