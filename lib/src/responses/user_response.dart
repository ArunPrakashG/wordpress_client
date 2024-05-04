import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/avatar_urls.dart';
import 'properties/extra_capabilities.dart';

@immutable
final class User implements ISelfRespresentive {
  const User({
    required this.id,
    required this.url,
    required this.link,
    required this.slug,
    required this.roles,
    required this.capabilities,
    required this.self,
    this.name,
    this.description,
    this.avatarUrls,
    this.email,
    this.firstName,
    this.lastName,
    this.extraCapabilities,
    this.registeredDate,
    this.username,
    this.nickname,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: castOrElse(json['id']),
      name: castOrElse(json['name']),
      username: castOrElse(json['username']),
      firstName: castOrElse(json['first_name']),
      lastName: castOrElse(json['last_name']),
      email: castOrElse(json['email']),
      nickname: castOrElse(json['nick_name']),
      registeredDate: parseDateIfNotNull(castOrElse(json['registered_date'])),
      capabilities: castOrElse(
        json['capabilities'],
        orElse: () => <String, bool>{},
        transformer: (value) {
          return Map<String, bool>.from(value as Map<String, dynamic>);
        },
      )!,
      extraCapabilities: castOrElse(
        json['extra_capabilities'],
        transformer: (value) => ExtraCapabilities.fromJson(
          value as Map<String, dynamic>,
        ),
      ),
      url: castOrElse(json['url']),
      description: castOrElse(json['description']),
      link: castOrElse(json['link']),
      slug: castOrElse(json['slug']),
      roles: mapIterableWithChecks<String>(
        json['roles'],
        (dynamic value) => value as String,
      ),
      avatarUrls: castOrElse(
        json['avatar_urls'],
        transformer: (dynamic value) {
          return AvatarUrls.fromJson(value as Map<String, dynamic>);
        },
      ),
      self: json,
    );
  }

  final int id;
  final String? username;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? email;
  final DateTime? registeredDate;
  final Map<String, bool> capabilities;
  final ExtraCapabilities? extraCapabilities;
  final String url;
  final String? description;
  final String link;
  final String slug;
  final List<String> roles;
  final AvatarUrls? avatarUrls;

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
      'avatar_urls': avatarUrls?.toJson(),
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
        self.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, firstName: $firstName, lastName: $lastName, nickname: $nickname, email: $email, registeredDate: $registeredDate, capabilities: $capabilities, extraCapabilities: $extraCapabilities, url: $url, description: $description, link: $link, slug: $slug, roles: $roles, avatarUrls: $avatarUrls, self: $self)';
  }
}
