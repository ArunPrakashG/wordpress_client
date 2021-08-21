import 'dart:convert';

import 'package:wordpress_client/src/utilities/serializable_instance.dart';

import 'partial_responses/links.dart';

class Category extends ISerializable<Category> {
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

  final int? id;
  final int? count;
  final String? description;
  final String? link;
  final String? name;
  final String? slug;
  final String? taxonomy;
  final int? parent;
  final List<dynamic>? meta;
  final Links? links;

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"] == null ? null : json["id"],
        count: json["count"] == null ? null : json["count"],
        description: json["description"] == null ? null : json["description"],
        link: json["link"] == null ? null : json["link"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        taxonomy: json["taxonomy"] == null ? null : json["taxonomy"],
        parent: json["parent"] == null ? null : json["parent"],
        meta: json["meta"] == null
            ? null
            : List<dynamic>.from(json["meta"].map((x) => x)),
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
        "parent": parent == null ? null : parent,
        "meta": meta == null ? null : List<dynamic>.from(meta!.map((x) => x)),
        "_links": links == null ? null : links!.toMap(),
      };

  @override
  Category fromJson(Map<String, dynamic>? json) => Category.fromMap(json!);

  @override
  Map<String, dynamic> toJson() => toMap();
}
