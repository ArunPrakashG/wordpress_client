// To parse this JSON data, do
//
//     final user = userFromMap(jsonString);

import 'dart:convert';

import 'package:wordpress_client/src/utilities/serializable_instance.dart';

import 'partial_responses/links.dart';

class User implements ISerializable<User> {
  User({
    this.id,
    this.name,
    this.url,
    this.description,
    this.link,
    this.slug,
    this.roles,
    this.avatarUrls,
    this.meta,
    this.yoastHead,
    this.links,
  });

  final int id;
  final String name;
  final String url;
  final String description;
  final String link;
  final String slug;
  final List<String> roles;
  final Map<String, String> avatarUrls;
  final List<dynamic> meta;
  final String yoastHead;
  final Links links;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        url: json["url"] == null ? null : json["url"],
        description: json["description"] == null ? null : json["description"],
        link: json["link"] == null ? null : json["link"],
        slug: json["slug"] == null ? null : json["slug"],
        roles: json["roles"] == null ? null : List<String>.from(json["roles"].map((x) => x)),
        avatarUrls: json["avatar_urls"] == null ? null : Map.from(json["avatar_urls"]).map((k, v) => MapEntry<String, String>(k, v)),
        meta: json["meta"] == null ? null : List<dynamic>.from(json["meta"].map((x) => x)),
        yoastHead: json["yoast_head"] == null ? null : json["yoast_head"],
        links: json["_links"] == null ? null : Links.fromMap(json["_links"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "url": url == null ? null : url,
        "description": description == null ? null : description,
        "link": link == null ? null : link,
        "slug": slug == null ? null : slug,
        "roles": roles == null ? null : List<dynamic>.from(roles.map((x) => x)),
        "avatar_urls": avatarUrls == null ? null : Map.from(avatarUrls).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "meta": meta == null ? null : List<dynamic>.from(meta.map((x) => x)),
        "yoast_head": yoastHead == null ? null : yoastHead,
        "_links": links == null ? null : links.toMap(),
      };

  @override
  User fromJson(Map<String, dynamic> json) => User.fromMap(json);

  @override
  Map<String, dynamic> toJson() => toMap();
}
