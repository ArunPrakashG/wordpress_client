import '../interfaces/serializable_base.dart';
import 'properties/links.dart';

class Tag extends ISerializable<Tag> {
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

  @override
  Tag fromMap(Map<String, dynamic> map) {
    return Tag.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap() {
    return toJson();
  }

  @override
  List<Object?> get props {
    return [
      id,
      count,
      description,
      link,
      name,
      slug,
      taxonomy,
      meta,
      links,
    ];
  }

  Tag copyWith({
    int? id,
    int? count,
    String? description,
    String? link,
    String? name,
    String? slug,
    String? taxonomy,
    dynamic meta,
    Links? links,
  }) {
    return Tag(
      id: id ?? this.id,
      count: count ?? this.count,
      description: description ?? this.description,
      link: link ?? this.link,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      taxonomy: taxonomy ?? this.taxonomy,
      meta: meta ?? this.meta,
      links: links ?? this.links,
    );
  }
}
