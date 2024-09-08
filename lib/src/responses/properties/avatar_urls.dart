import 'package:meta/meta.dart';

import '../../library_exports.dart';

/// Represents the avatar URLs for a user in the WordPress REST API.
///
/// This class encapsulates the URLs for different sizes of a user's avatar image.
/// The WordPress REST API provides avatar URLs in three standard sizes: 24x24, 48x48, and 96x96 pixels.
///
/// According to the WordPress REST API Handbook:
/// - Avatar URLs are typically generated using the Gravatar service.
/// - The size of the avatar can be adjusted by modifying the URL parameters.
/// - If no avatar is available, a default image or generated avatar may be provided.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/users/#schema-avatar_urls
@immutable
final class AvatarUrls {
  /// Creates a new [AvatarUrls] instance.
  ///
  /// All parameters are optional and can be null if not provided.
  /// - [small24]: URL for the 24x24 pixel avatar image.
  /// - [medium48]: URL for the 48x48 pixel avatar image.
  /// - [large96]: URL for the 96x96 pixel avatar image.
  const AvatarUrls({
    this.small24,
    this.medium48,
    this.large96,
  });

  /// Creates an [AvatarUrls] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data returned by the WordPress REST API.
  /// It uses the [castOrElse] utility function to safely cast values or provide defaults.
  factory AvatarUrls.fromJson(Map<String, dynamic> json) {
    return AvatarUrls(
      small24: castOrElse(json['24']),
      medium48: castOrElse(json['48']),
      large96: castOrElse(json['96']),
    );
  }

  /// The URL for the 24x24 pixel avatar image.
  final String? small24;

  /// The URL for the 48x48 pixel avatar image.
  final String? medium48;

  /// The URL for the 96x96 pixel avatar image.
  final String? large96;

  /// Converts this [AvatarUrls] instance to a JSON-compatible map.
  ///
  /// This method is useful for serializing the object, for example, when sending data to the API.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '24': small24,
      '48': medium48,
      '96': large96,
    };
  }

  /// Creates a copy of this [AvatarUrls] instance with the given fields replaced with new values.
  ///
  /// This method is useful for updating specific fields of an [AvatarUrls] instance
  /// while keeping the other fields unchanged.
  AvatarUrls copyWith({
    String? small24,
    String? medium48,
    String? large96,
  }) {
    return AvatarUrls(
      small24: small24 ?? this.small24,
      medium48: medium48 ?? this.medium48,
      large96: large96 ?? this.large96,
    );
  }

  @override
  String toString() =>
      'AvatarUrls(small24: $small24, medium48: $medium48, large96: $large96)';

  @override
  bool operator ==(covariant AvatarUrls other) {
    if (identical(this, other)) {
      return true;
    }

    return other.small24 == small24 &&
        other.medium48 == medium48 &&
        other.large96 == large96;
  }

  @override
  int get hashCode => small24.hashCode ^ medium48.hashCode ^ large96.hashCode;
}
