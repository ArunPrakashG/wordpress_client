import 'response_properties/links.dart';

class Tag {
  Tag({
    this.id,
    this.count,
    this.description,
    this.link,
    this.name,
    this.slug,
    this.taxonomy,
    this.meta,
    this.links,
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
      links: Links.fromJson(json['_links']),
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
}
