import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/links.dart';

@immutable
final class WordpressDiscovery implements ISelfRespresentive {
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
    this.links,
  });

  factory WordpressDiscovery.fromJson(Map<String, dynamic> map) {
    return WordpressDiscovery(
      siteIconUrl: castOrElse(map['site_icon_url']),
      siteIcon: castOrElse(map['site_icon']),
      siteLogo: castOrElse(map['site_logo']),
      links: castOrElse(
        map['_links'],
        transformer: (value) => Links.fromJson(value as Map<String, dynamic>),
      ),
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

  final String siteIconUrl;
  final int siteIcon;
  final int siteLogo;
  final Links? links;
  final String name;
  final String description;
  final String url;
  final String home;
  final double gmtOffset;
  final String timezoneString;
  final List<String> namespaces;
  final Map<String, dynamic> authentication;
  final Map<String, dynamic> routes;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'site_icon_url': siteIconUrl,
      'site_icon': siteIcon,
      'site_logo': siteLogo,
      '_links': links?.toJson(),
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
