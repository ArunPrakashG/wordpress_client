import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents the WordPress site information and API capabilities.
///
/// This class encapsulates the data returned by the WordPress REST API's root endpoint,
/// which provides information about the site and available API routes.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/
@immutable
final class WordpressDiscovery implements ISelfRespresentive {
  /// Creates a new [WordpressDiscovery] instance.
  const WordpressDiscovery({
    required this.siteIconUrl,
    required this.siteIcon,
    required this.siteLogo,
    required this.name,
    required this.description,
    required this.url,
    required this.home,
    required this.gmtOffset,
    required this.timezoneString,
    required this.namespaces,
    required this.authentication,
    required this.routes,
    required this.self,
  });

  /// Creates a [WordpressDiscovery] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize site information data
  /// received from the WordPress REST API's root endpoint.
  factory WordpressDiscovery.fromJson(Map<String, dynamic> map) {
    return WordpressDiscovery(
      siteIconUrl: castOrElse<String>(
        map['site_icon_url'],
        orElse: () => '',
      )!,
      siteIcon: castOrElse<int>(
        map['site_icon'],
        transformer: (v) {
          if (v is int) return v;
          if (v is String) return int.tryParse(v);
          return null;
        },
        orElse: () => 0,
      )!,
      siteLogo: castOrElse<int>(
        map['site_logo'],
        transformer: (v) {
          if (v is int) return v;
          if (v is String) return int.tryParse(v);
          return null;
        },
        orElse: () => 0,
      )!,
      name: castOrElse<String>(map['name'], orElse: () => '')!,
      description: castOrElse<String>(map['description'], orElse: () => '')!,
      url: castOrElse<String>(map['url'], orElse: () => '')!,
      home: castOrElse<String>(map['home'], orElse: () => '')!,
      gmtOffset: castOrElse<double>(
        map['gmt_offset'],
        transformer: (v) {
          if (v is num) return v.toDouble();
          if (v is String) return double.tryParse(v);
          return null;
        },
        orElse: () => 0.0,
      )!,
      timezoneString:
          castOrElse<String>(map['timezone_string'], orElse: () => '')!,
      namespaces: mapIterableWithChecks(
        map['namespaces'],
        (dynamic json) => json as String,
      ),
      authentication: castOrElse<Map<String, dynamic>>(
            map['authentication'],
            transformer: (v) => v as Map<String, dynamic>?,
            orElse: () => <String, dynamic>{},
          ) ??
          <String, dynamic>{},
      routes: castOrElse<Map<String, dynamic>>(
            map['routes'],
            transformer: (v) => v as Map<String, dynamic>?,
            orElse: () => <String, dynamic>{},
          ) ??
          <String, dynamic>{},
      self: map,
    );
  }

  /// The URL of the site's icon.
  final String siteIconUrl;

  /// The ID of the attachment used as the site icon.
  final int siteIcon;

  /// The ID of the attachment used as the site logo.
  final int siteLogo;

  /// The name of the site.
  final String name;

  /// A brief description of the site.
  final String description;

  /// The URL of the site.
  final String url;

  /// The homepage URL of the site.
  final String home;

  /// Offset of the site's timezone from UTC.
  final double gmtOffset;

  /// String representation of the site's timezone.
  final String timezoneString;

  /// List of API namespaces supported by the site.
  final List<String> namespaces;

  /// Information about authentication methods supported by the API.
  final Map<String, dynamic> authentication;

  /// Available API routes and their endpoints.
  final Map<String, dynamic> routes;

  /// The raw JSON response from the API.
  @override
  final Map<String, dynamic> self;

  /// Converts the [WordpressDiscovery] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'site_icon_url': siteIconUrl,
      'site_icon': siteIcon,
      'site_logo': siteLogo,
      'name': name,
      'description': description,
      'url': url,
      'home': home,
      'gmt_offset': gmtOffset,
      'timezone_string': timezoneString,
      'namespaces': namespaces,
      'authentication': authentication,
      'routes': routes,
    };
  }
}
