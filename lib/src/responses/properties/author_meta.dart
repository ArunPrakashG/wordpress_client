import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

/// Represents metadata for an author in the WordPress REST API.
///
/// This class encapsulates various properties related to an author. It provides a structured way to handle
/// author metadata in Dart applications interfacing with WordPress.
///
/// This class is only used if you have the additional plugin integrated in your wordpress site.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/users/
@immutable
final class AuthorMeta {
  /// Creates an instance of [AuthorMeta].
  ///
  /// [id] is required and represents the unique identifier for the author.
  /// Other parameters are optional and correspond to various author attributes.
  const AuthorMeta({
    required this.id,
    this.userNicename,
    this.userRegistered,
    this.displayName,
  });

  /// Creates an [AuthorMeta] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize author metadata from
  /// the WordPress REST API response.
  ///
  /// [json] is a map containing the author metadata as returned by the API.
  factory AuthorMeta.fromJson(Map<String, dynamic> json) {
    return AuthorMeta(
      id: castOrElse(json['ID']),
      userNicename: castOrElse(json['user_nicename']),
      userRegistered: parseDateIfNotNull(castOrElse(json['user_registered'])),
      displayName: castOrElse(json['display_name']),
    );
  }

  /// The unique identifier for the author.
  ///
  /// This corresponds to the 'ID' field in the WordPress REST API.
  final String id;

  /// The 'nice name' of the author, used for URLs and slugs.
  ///
  /// This corresponds to the 'user_nicename' field in the WordPress REST API.
  /// It's typically a URL-friendly version of the user's name or username.
  final String? userNicename;

  /// The date and time when the author's account was registered.
  ///
  /// This corresponds to the 'user_registered' field in the WordPress REST API.
  /// It represents the date and time when the user account was created.
  final DateTime? userRegistered;

  /// The display name of the author.
  ///
  /// This corresponds to the 'display_name' field in the WordPress REST API.
  /// It's the name chosen by the user to be displayed publicly on the site.
  final String? displayName;

  /// Converts the [AuthorMeta] instance to a JSON map.
  ///
  /// This method is used for serializing the author metadata, which can be
  /// useful when sending data back to the WordPress REST API or storing it.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ID': id,
      'user_nicename': userNicename,
      'user_registered': userRegistered?.toIso8601String(),
      'display_name': displayName,
    };
  }

  @override
  bool operator ==(covariant AuthorMeta other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id &&
        other.userNicename == userNicename &&
        other.userRegistered == userRegistered &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userNicename.hashCode ^
        userRegistered.hashCode ^
        displayName.hashCode;
  }

  @override
  String toString() {
    return 'AuthorMeta(id: $id, userNicename: $userNicename, userRegistered: $userRegistered, displayName: $displayName)';
  }
}
