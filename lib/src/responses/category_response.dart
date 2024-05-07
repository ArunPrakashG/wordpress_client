import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

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
  });

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
      self: json as Map<String, dynamic>,
    );
  }

  final int id;
  final int count;
  final String? description;
  final String? link;
  final String? name;
  final String slug;
  final String? taxonomy;
  final int? parent;

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
        self.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, parent: $parent, self: $self)';
  }
}
