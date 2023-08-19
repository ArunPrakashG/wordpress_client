import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/links.dart';

@immutable
class Category implements ISelfRespresentive {
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
    this.links,
  });

  factory Category.fromJson(dynamic json) {
    return Category(
      id: castOrElse(json['id']),
      count: castOrElse(json['count'], orElse: () => 0)!,
      description: castOrElse(json['description'], orElse: () => '')!,
      link: castOrElse(json['link'], orElse: () => '')!,
      name: castOrElse(json['name'], orElse: () => ''),
      slug: castOrElse(json['slug'], orElse: () => '')!,
      taxonomy: castOrElse(json['taxonomy'], orElse: () => '')!,
      parent: castOrElse(json['parent'], orElse: () => 0)!,
      meta: json['meta'],
      links: castOrElse(
        json['_links'],
        transformer: (value) => Links.fromJson(value as Map<String, dynamic>),
      ),
      self: json as Map<String, dynamic>,
    );
  }

  final int id;
  final int count;
  final String description;
  final String link;
  final String? name;
  final String slug;
  final String taxonomy;
  final int parent;
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
