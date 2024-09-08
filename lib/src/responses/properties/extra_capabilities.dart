import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

/// Represents the extra capabilities of a user in the WordPress REST API.
///
/// This class encapsulates additional capabilities that a user might have,
/// beyond the standard WordPress roles. In the current implementation,
/// it focuses on the 'administrator' capability, but it can be extended
/// to include other custom capabilities as needed.
///
/// According to the WordPress REST API Handbook:
/// - Extra capabilities are specific to the site's configuration and plugins.
/// - They are typically used to grant or restrict access to certain features or content.
/// - The 'administrator' capability is one of the most powerful, granting full access to all areas of the WordPress admin.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/users/#schema-extra_capabilities
@immutable
final class ExtraCapabilities {
  /// Creates a new [ExtraCapabilities] instance.
  ///
  /// [administrator] is a required parameter indicating whether the user has administrator capabilities.
  const ExtraCapabilities({
    required this.administrator,
  });

  /// Creates an [ExtraCapabilities] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data returned by the WordPress REST API.
  /// It uses the [castOrElse] utility function to safely cast the 'administrator' value or provide a default.
  factory ExtraCapabilities.fromJson(Map<String, dynamic> json) {
    return ExtraCapabilities(
      administrator: castOrElse(json['administrator'], orElse: () => false)!,
    );
  }

  /// Indicates whether the user has administrator capabilities.
  ///
  /// If true, the user has full access to all areas of the WordPress admin.
  final bool administrator;

  /// Converts this [ExtraCapabilities] instance to a JSON-compatible map.
  ///
  /// This method is useful for serializing the object, for example, when sending data to the API.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'administrator': administrator,
    };
  }

  @override
  bool operator ==(covariant ExtraCapabilities other) {
    if (identical(this, other)) {
      return true;
    }

    return other.administrator == administrator;
  }

  @override
  int get hashCode => administrator.hashCode;

  @override
  String toString() => 'ExtraCapabilities(administrator: $administrator)';
}
