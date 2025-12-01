import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a Site Editor Template Part (wp/v2/template-parts).
@immutable
final class TemplatePart implements ISelfRespresentive {
  const TemplatePart({
    required this.id,
    required this.slug,
    required this.theme,
    required this.type,
    required this.status,
    required this.hasThemeFile,
    required this.wpId,
    required this.self,
    this.source,
    this.origin,
    this.content,
    this.title,
    this.description,
    this.author,
    this.modified,
    this.area,
  });

  factory TemplatePart.fromJson(Map<String, dynamic> json) {
    return TemplatePart(
      id: castOrElse(json['id'], orElse: () => '')!,
      slug: castOrElse(json['slug'], orElse: () => '')!,
      theme: castOrElse(json['theme'], orElse: () => '')!,
      type: castOrElse(json['type'], orElse: () => '')!,
      source: castOrElse(json['source']),
      origin: castOrElse(json['origin']),
      content: _parseContent(json['content']),
      title: castOrElse(
        json['title'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      description: castOrElse(json['description']),
      status: getContentStatusFromValue(castOrElse(json['status'])),
      wpId: castOrElse(json['wp_id'], orElse: () => 0)!,
      hasThemeFile: castOrElse(json['has_theme_file'], orElse: () => false)!,
      author: castOrElse(json['author']),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      area: castOrElse(json['area']),
      self: json,
    );
  }

  /// Attempts to normalize the template part content into a single string value.
  static String? _parseContent(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final raw = castOrElse<String>(value['raw']);
      if (raw != null) return raw;
      final rendered = castOrElse<String>(value['rendered']);
      if (rendered != null) return rendered;
    }
    return value.toString();
  }

  final String id;
  final String slug;
  final String theme;
  final String type;
  final String? source;
  final String? origin;
  final String? content;
  final Content? title;
  final String? description;
  final ContentStatus status;
  final int wpId;
  final bool hasThemeFile;
  final int? author;
  final DateTime? modified;
  final String? area;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slug': slug,
        'theme': theme,
        'type': type,
        'source': source,
        'origin': origin,
        'content': content,
        'title': title?.toJson(),
        'description': description,
        'status': status.name,
        'wp_id': wpId,
        'has_theme_file': hasThemeFile,
        'author': author,
        'modified': modified?.toIso8601String(),
        'area': area,
      };

  @override
  bool operator ==(covariant TemplatePart other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.slug == slug &&
        other.theme == theme &&
        other.type == type &&
        other.source == source &&
        other.origin == origin &&
        other.content == content &&
        other.description == description &&
        other.status == status &&
        other.wpId == wpId &&
        other.hasThemeFile == hasThemeFile &&
        other.author == author &&
        other.modified == modified &&
        other.area == area &&
        eq(other.title?.toJson(), title?.toJson()) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      slug.hashCode ^
      theme.hashCode ^
      type.hashCode ^
      (source?.hashCode ?? 0) ^
      (origin?.hashCode ?? 0) ^
      (content?.hashCode ?? 0) ^
      (title?.hashCode ?? 0) ^
      (description?.hashCode ?? 0) ^
      status.hashCode ^
      wpId.hashCode ^
      hasThemeFile.hashCode ^
      (author?.hashCode ?? 0) ^
      (modified?.hashCode ?? 0) ^
      (area?.hashCode ?? 0) ^
      self.hashCode;
}
