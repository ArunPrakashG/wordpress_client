import 'dart:convert';

import '../utilities/serializable_instance.dart';
import 'partial_responses/links.dart';

class Tag extends ISerializable<Tag> {
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

  final int id;
  final int count;
  final String description;
  final String link;
  final String name;
  final String slug;
  final String taxonomy;
  final List<dynamic> meta;
  final Links links;

  factory Tag.fromJson(String str) => Tag.fromMap(json.decode(str));

  factory Tag.fromMap(Map<String, dynamic> json) => Tag(
        id: json["id"] == null ? null : json["id"],
        count: json["count"] == null ? null : json["count"],
        description: json["description"] == null ? null : json["description"],
        link: json["link"] == null ? null : json["link"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        taxonomy: json["taxonomy"] == null ? null : json["taxonomy"],
        meta: json["meta"] == null ? null : List<dynamic>.from(json["meta"].map((x) => x)),
        links: json["_links"] == null ? null : Links.fromMap(json["_links"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "count": count == null ? null : count,
        "description": description == null ? null : description,
        "link": link == null ? null : link,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "taxonomy": taxonomy == null ? null : taxonomy,
        "meta": meta == null ? null : List<dynamic>.from(meta.map((x) => x)),
        "_links": links == null ? null : links.toMap(),
      };

  @override
  Tag fromJson(Map<String, dynamic> json) => Tag.fromMap(json);

  @override
  Map<String, dynamic> toJson() => toMap();
}
