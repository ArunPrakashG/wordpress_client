import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

@immutable
final class Tag implements ISelfRespresentive {
  const Tag({
    required this.id,
    required this.count,
    required this.link,
    required this.slug,
    required this.taxonomy,
    required this.self,
    this.description,
    this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: castOrElse(json['id']),
      count: castOrElse(json['count']),
      description: castOrElse(json['description']),
      link: castOrElse(json['link']),
      name: castOrElse(json['name']),
      slug: castOrElse(json['slug']),
      taxonomy: castOrElse(json['taxonomy']),
      self: json,
    );
  }

  final int id;
  final int count;
  final String? description;
  final String link;
  final String? name;
  final String slug;
  final String taxonomy;

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
    };
  }

  @override
  bool operator ==(covariant Tag other) {
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
        self.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, self: $self)';
  }
}
