// To parse this JSON data, do
//
//     final user = userFromMap(jsonString);

import 'dart:convert';

import 'package:wordpress_client/src/utilities/serializable_instance.dart';

import 'partial_responses/extra_capabilities.dart';
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
    this.capabilities,
    this.email,
    this.firstName,
    this.lastName,
    this.nickname,
    this.extraCapabilities,
    this.registeredDate,
    this.username,
  });

  final int? id;
  final String? username;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? email;
  final DateTime? registeredDate;
  final Map<String, bool>? capabilities;
  final ExtraCapabilities? extraCapabilities;
  final String? url;
  final String? description;
  final String? link;
  final String? slug;
  final List<String>? roles;
  final Map<String, String>? avatarUrls;
  final List<dynamic>? meta;
  final String? yoastHead;
  final Links? links;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        username: json["username"] == null ? null : json["username"],
        firstName: json["first_name"] == null ? null : json["first_name"],
        lastName: json["last_name"] == null ? null : json["last_name"],
        email: json["email"] == null ? null : json["email"],
        registeredDate: json["registered_date"] == null
            ? null
            : DateTime.parse(json["registered_date"]),
        capabilities: json["capabilities"] == null
            ? null
            : Map.from(json["capabilities"])
                .map((k, v) => MapEntry<String, bool>(k, v)),
        extraCapabilities: json["extra_capabilities"] == null
            ? null
            : ExtraCapabilities.fromMap(json["extra_capabilities"]),
        url: json["url"] == null ? null : json["url"],
        description: json["description"] == null ? null : json["description"],
        link: json["link"] == null ? null : json["link"],
        slug: json["slug"] == null ? null : json["slug"],
        roles: json["roles"] == null
            ? null
            : List<String>.from(json["roles"].map((x) => x)),
        avatarUrls: json["avatar_urls"] == null
            ? null
            : Map.from(json["avatar_urls"])
                .map((k, v) => MapEntry<String, String>(k, v)),
        meta: json["meta"] == null
            ? null
            : List<dynamic>.from(json["meta"].map((x) => x)),
        yoastHead: json["yoast_head"] == null ? null : json["yoast_head"],
        links: json["_links"] == null ? null : Links.fromMap(json["_links"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "url": url == null ? null : url,
        "username": username == null ? null : username,
        "first_name": firstName == null ? null : firstName,
        "last_name": lastName == null ? null : lastName,
        "email": email == null ? null : email,
        "description": description == null ? null : description,
        "link": link == null ? null : link,
        "slug": slug == null ? null : slug,
        "registered_date":
            registeredDate == null ? null : registeredDate!.toIso8601String(),
        "capabilities": capabilities == null
            ? null
            : Map.from(capabilities!)
                .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "extra_capabilities":
            extraCapabilities == null ? null : extraCapabilities!.toMap(),
        "roles":
            roles == null ? null : List<dynamic>.from(roles!.map((x) => x)),
        "avatar_urls": avatarUrls == null
            ? null
            : Map.from(avatarUrls!)
                .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "meta": meta == null ? null : List<dynamic>.from(meta!.map((x) => x)),
        "yoast_head": yoastHead == null ? null : yoastHead,
        "_links": links == null ? null : links!.toMap(),
      };

  @override
  User fromJson(Map<String, dynamic>? json) => User.fromMap(json!);

  @override
  Map<String, dynamic> toJson() => toMap();
}
