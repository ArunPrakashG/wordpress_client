import '../utilities/helpers.dart';
import 'response_properties/extra_capabilities.dart';
import 'response_properties/links.dart';

class User {
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

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      registeredDate: parseDateIfNotNull(json['registered_date']),
      capabilities: json['capabilities'] == null
          ? null
          : Map<String, bool>.from(json['capabilities'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v)),
      extraCapabilities: ExtraCapabilities.fromJson(json['extra_capabilities']),
      url: json['url'] as String?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      slug: json['slug'] as String?,
      roles: mapIterableWithChecks<String>(
          json['roles'], (dynamic value) => value as String),
      avatarUrls: json['avatar_urls'] == null
          ? null
          : Map<String, String>.from(
                  json['avatar_urls'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v)),
      meta: json['meta'],
      links: Links.fromJson(json['_links']),
    );
  }

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
  final dynamic meta;
  final Links? links;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'description': description,
      'link': link,
      'slug': slug,
      'registered_date': registeredDate?.toIso8601String(),
      'capabilities': capabilities,
      'extra_capabilities': extraCapabilities?.toJson(),
      'roles': roles,
      'avatar_urls': avatarUrls,
      'meta': meta,
      '_links': links?.toJson(),
    };
  }
}
