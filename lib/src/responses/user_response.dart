import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/avatar_urls.dart';
import 'properties/extra_capabilities.dart';

/// Represents a WordPress user.
///
/// This class encapsulates all the properties of a WordPress user as defined in the
/// WordPress REST API. It provides a structured way to work with user data in Dart applications.
///
/// For more information, see the WordPress REST API handbook:
/// https://developer.wordpress.org/rest-api/reference/users/
@immutable
final class User implements ISelfRespresentive {
  /// Creates a new [User] instance.
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
    this.locale,
    this.meta,
  });

  /// Creates a [User] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize user data received from the WordPress REST API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: castOrElse(json['id']),
      name: castOrElse(json['name']),
      username: castOrElse(json['username']),
      firstName: castOrElse(json['first_name']),
      lastName: castOrElse(json['last_name']),
      email: castOrElse(json['email']),
      nickname: castOrElse(json['nickname']),
      locale: castOrElse(json['locale']),
      registeredDate: parseDateIfNotNull(castOrElse(json['registered_date'])),
      capabilities: castOrElse(
        json['capabilities'],
        orElse: () => <String, bool>{},
        transformer: (value) {
          return Map<String, bool>.from(value as Map<String, dynamic>);
        },
      )!,
      meta: castOrElse(json['meta']),
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

  /// Unique identifier for the user.
  final int id;

  /// Login name for the user.
  final String? username;

  /// Display name for the user.
  final String? name;

  /// First name for the user.
  final String? firstName;

  /// Last name for the user.
  final String? lastName;

  /// The nickname for the user.
  final String? nickname;

  /// Locale for the user.
  final String? locale;

  /// The email address for the user.
  final String? email;

  /// Registration date for the user.
  final DateTime? registeredDate;

  /// All capabilities assigned to the user.
  final Map<String, bool> capabilities;

  /// Extra capabilities assigned to the user.
  final ExtraCapabilities? extraCapabilities;

  /// URL of the user.
  final String url;

  /// Description of the user.
  final String? description;

  /// Author URL of the user.
  final String link;

  /// An alphanumeric identifier for the user.
  final String slug;

  /// Roles assigned to the user.
  final List<String> roles;

  /// Avatar URLs for the user.
  final AvatarUrls? avatarUrls;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  /// The raw data received from the API.
  @override
  final Map<String, dynamic> self;

  /// Converts the [User] instance to a JSON map.
  ///
  /// This method is used to serialize the user data for sending to the WordPress REST API.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'nickname': nickname,
      'locale': locale,
      'email': email,
      'description': description,
      'link': link,
      'slug': slug,
      'registered_date': registeredDate?.toIso8601String(),
      'capabilities': capabilities,
      'meta': meta,
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
        other.locale == locale &&
        collectionEquals(other.capabilities, capabilities) &&
        collectionEquals(other.meta, meta) &&
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
        locale.hashCode ^
        capabilities.hashCode ^
        meta.hashCode ^
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
    return 'User(id: $id, username: $username, name: $name, firstName: $firstName, lastName: $lastName, nickname: $nickname, locale: $locale, email: $email, registeredDate: $registeredDate, capabilities: $capabilities, meta: $meta, extraCapabilities: $extraCapabilities, url: $url, description: $description, link: $link, slug: $slug, roles: $roles, avatarUrls: $avatarUrls, self: $self)';
  }
}
