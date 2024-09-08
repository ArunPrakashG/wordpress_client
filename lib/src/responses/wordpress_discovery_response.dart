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
      siteIconUrl: castOrElse(map['site_icon_url']),
      siteIcon: castOrElse(map['site_icon']),
      siteLogo: castOrElse(map['site_logo']),
      name: castOrElse(map['name']),
      description: castOrElse(map['description']),
      url: castOrElse(map['url']),
      home: castOrElse(map['home']),
      gmtOffset: castOrElse(map['gmt_offset']),
      timezoneString: castOrElse(map['timezone_string']),
      namespaces: mapIterableWithChecks(
        map['namespaces'],
        (dynamic json) => json as String,
      ),
      authentication: map['authentication'],
      routes: map['routes'],
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
