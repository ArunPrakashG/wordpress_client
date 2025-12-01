import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a WordPress Theme (wp/v2/themes).
@immutable
final class Theme implements ISelfRespresentive {
  const Theme({
    required this.stylesheet,
    required this.self,
    this.name,
    this.version,
    this.author,
    this.authorUri,
    this.description,
    this.isBlockTheme,
    this.tags,
    this.template,
    this.textDomain,
    this.status,
    this.themeUri,
    this.screenshot,
    this.themeSupports,
    this.requiresPhp,
    this.requiresWp,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      stylesheet: castOrElse(json['stylesheet'], orElse: () => '')!,
      name: castOrElse(json['name']),
      version: castOrElse(json['version']),
      author: castOrElse(json['author']),
      authorUri: castOrElse(json['author_uri']),
      description: castOrElse(json['description']),
      isBlockTheme: castOrElse(json['is_block_theme']),
      tags: mapIterableWithChecks<String>(
        json['tags'],
        (dynamic v) => v as String,
      ),
      template: castOrElse(json['template']),
      textDomain: castOrElse(json['textdomain']),
      status: castOrElse(json['status']),
      screenshot: castOrElse(json['screenshot']),
      themeSupports: castOrElse<Map<String, dynamic>>(json['theme_supports']),
      themeUri: castOrElse(json['theme_uri']),
      requiresPhp: castOrElse(json['requires_php']),
      requiresWp: castOrElse(json['requires_wp']),
      self: json,
    );
  }

  final String stylesheet;
  final String? name;
  final String? version;
  final String? author;
  final String? authorUri;
  final String? description;
  final bool? isBlockTheme;
  final List<String>? tags;
  final String? template;
  final String? textDomain;
  final String? status;
  final String? screenshot;
  final Map<String, dynamic>? themeSupports;
  final String? themeUri;
  final String? requiresPhp;
  final String? requiresWp;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stylesheet': stylesheet,
        'name': name,
        'version': version,
        'author': author,
        'author_uri': authorUri,
        'description': description,
        'is_block_theme': isBlockTheme,
        'tags': tags,
        'template': template,
        'textdomain': textDomain,
        'status': status,
        'screenshot': screenshot,
        'theme_supports': themeSupports,
        'theme_uri': themeUri,
        'requires_php': requiresPhp,
        'requires_wp': requiresWp,
      };

  @override
  bool operator ==(covariant Theme other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.stylesheet == stylesheet &&
        other.name == name &&
        other.version == version &&
        other.author == author &&
        other.authorUri == authorUri &&
        other.description == description &&
        other.isBlockTheme == isBlockTheme &&
        eq(other.tags, tags) &&
        other.template == template &&
        other.textDomain == textDomain &&
        other.status == status &&
        other.screenshot == screenshot &&
        eq(other.themeSupports, themeSupports) &&
        other.themeUri == themeUri &&
        other.requiresPhp == requiresPhp &&
        other.requiresWp == requiresWp &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      stylesheet.hashCode ^
      name.hashCode ^
      version.hashCode ^
      author.hashCode ^
      authorUri.hashCode ^
      description.hashCode ^
      isBlockTheme.hashCode ^
      tags.hashCode ^
      template.hashCode ^
      textDomain.hashCode ^
      status.hashCode ^
      (screenshot?.hashCode ?? 0) ^
      (themeSupports?.hashCode ?? 0) ^
      themeUri.hashCode ^
      requiresPhp.hashCode ^
      requiresWp.hashCode ^
      self.hashCode;
}
