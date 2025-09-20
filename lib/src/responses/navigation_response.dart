import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a Site Navigation entity (wp/v2/navigation).
///
/// Schema reference:
/// https://developer.wordpress.org/rest-api/reference/wp_navigations/
@immutable
final class Navigation implements ISelfRespresentive {
  const Navigation({
    required this.id,
    required this.slug,
    required this.link,
    required this.status,
    required this.type,
    required this.self,
    this.date,
    this.dateGmt,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.password,
    this.title,
    this.content,
    this.template,
  });

  /// Creates a [Navigation] from REST API JSON.
  factory Navigation.fromJson(Map<String, dynamic> json) {
    return Navigation(
      id: castOrElse(json['id'], orElse: () => 0)!,
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      guid: castOrElse(
        json['guid'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      slug: castOrElse(json['slug'], orElse: () => '')!,
      status: getContentStatusFromValue(castOrElse(json['status'])),
      type: castOrElse(json['type'], orElse: () => '')!,
      link: castOrElse(json['link'], orElse: () => '')!,
      title: castOrElse(
        json['title'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      content: castOrElse(
        json['content'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      password: castOrElse(json['password']),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      modifiedGmt: parseDateIfNotNull(castOrElse(json['modified_gmt'])),
      template: castOrElse(json['template']),
      self: json,
    );
  }

  /// Unique identifier for the navigation (post ID).
  final int id;

  /// The date the navigation was published, in the site's timezone.
  final DateTime? date;

  /// The date the navigation was published, as GMT.
  final DateTime? dateGmt;

  /// The globally unique identifier for the navigation.
  final Content? guid;

  /// An alphanumeric identifier for the navigation unique to its type.
  final String slug;

  /// A named status for the navigation.
  final ContentStatus status;

  /// Type of post.
  final String type;

  /// URL to the navigation.
  final String link;

  /// The navigation title.
  final Content? title;

  /// The navigation content (blocks).
  final Content? content;

  /// A password to protect access to the content and excerpt.
  final String? password;

  /// The date the navigation was last modified, in the site's timezone.
  final DateTime? modified;

  /// The date the navigation was last modified, as GMT.
  final DateTime? modifiedGmt;

  /// The theme file to use to display the navigation.
  final String? template;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'date': date?.toIso8601String(),
        'date_gmt': dateGmt?.toIso8601String(),
        'guid': guid?.toJson(),
        'slug': slug,
        'status': status.name,
        'type': type,
        'link': link,
        'title': title?.toJson(),
        'content': content?.toJson(),
        'password': password,
        'modified': modified?.toIso8601String(),
        'modified_gmt': modifiedGmt?.toIso8601String(),
        'template': template,
      };

  @override
  bool operator ==(covariant Navigation other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.slug == slug &&
        other.link == link &&
        other.status == status &&
        other.type == type &&
        other.password == password &&
        other.date == date &&
        other.dateGmt == dateGmt &&
        other.modified == modified &&
        other.modifiedGmt == modifiedGmt &&
        other.template == template &&
        eq(other.guid?.toJson(), guid?.toJson()) &&
        eq(other.title?.toJson(), title?.toJson()) &&
        eq(other.content?.toJson(), content?.toJson()) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      slug.hashCode ^
      link.hashCode ^
      status.hashCode ^
      type.hashCode ^
      (password?.hashCode ?? 0) ^
      (date?.hashCode ?? 0) ^
      (dateGmt?.hashCode ?? 0) ^
      (modified?.hashCode ?? 0) ^
      (modifiedGmt?.hashCode ?? 0) ^
      (template?.hashCode ?? 0) ^
      (guid?.hashCode ?? 0) ^
      (title?.hashCode ?? 0) ^
      (content?.hashCode ?? 0) ^
      self.hashCode;
}
