import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'response_properties/extra_capabilities.dart';
import 'response_properties/links.dart';

@immutable
class User implements ISelfRespresentive {
  const User({
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
    this.extraCapabilities,
    this.registeredDate,
    this.username,
    this.nickname,
    required this.self,
  });

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      nickname: json['nick_name'] as String?,
      registeredDate: parseDateIfNotNull(json['registered_date']),
      capabilities: json['capabilities'] == null
          ? null
          : Map<String, bool>.from(json['capabilities'] as Map<String, dynamic>)
              .map(MapEntry.new),
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
              .map(MapEntry.new),
      meta: json['meta'],
      links: Links.fromJson(json['_links']),
      self: json as Map<String, dynamic>,
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

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'nick_name': nickname,
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

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) {
      return true;
    }

    final collectionEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.username == username &&
        other.name == name &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.nickname == nickname &&
        other.email == email &&
        other.registeredDate == registeredDate &&
        collectionEquals(other.capabilities, capabilities) &&
        other.extraCapabilities == extraCapabilities &&
        other.url == url &&
        other.description == description &&
        other.link == link &&
        other.slug == slug &&
        collectionEquals(other.roles, roles) &&
        collectionEquals(other.avatarUrls, avatarUrls) &&
        other.meta == meta &&
        other.links == links &&
        collectionEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        registeredDate.hashCode ^
        capabilities.hashCode ^
        extraCapabilities.hashCode ^
        url.hashCode ^
        description.hashCode ^
        link.hashCode ^
        slug.hashCode ^
        roles.hashCode ^
        avatarUrls.hashCode ^
        meta.hashCode ^
        links.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, firstName: $firstName, lastName: $lastName, nickname: $nickname, email: $email, registeredDate: $registeredDate, capabilities: $capabilities, extraCapabilities: $extraCapabilities, url: $url, description: $description, link: $link, slug: $slug, roles: $roles, avatarUrls: $avatarUrls, meta: $meta, links: $links, self: $self)';
  }
}
