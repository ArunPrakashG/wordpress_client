import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/self_representive_base.dart';
import 'response_properties/links.dart';

@immutable
class Tag implements ISelfRespresentive {
  const Tag({
    this.id,
    this.count,
    this.description,
    this.link,
    this.name,
    this.slug,
    this.taxonomy,
    this.meta,
    this.links,
    required this.self,
  });

  factory Tag.fromJson(dynamic json) {
    return Tag(
      id: json['id'] as int?,
      count: json['count'] as int?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      taxonomy: json['taxonomy'] as String?,
      meta: json['meta'],
      links: json?['_links'] != null ? Links.fromJson(json['_links']) : null,
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
  final dynamic meta;
  final Links? links;

  @override
  Map<String, dynamic> get json => self;

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
      'meta': meta,
      '_links': links?.toJson(),
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
        meta.hashCode ^
        links.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, meta: $meta, links: $links, self: $self)';
  }
}
