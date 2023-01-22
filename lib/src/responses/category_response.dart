import 'properties/links.dart';

class Category {
  Category({
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
  });

  factory Category.fromJson(dynamic json) => Category(
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
      );

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
}
