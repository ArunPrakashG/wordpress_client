import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a Site Editor Template (wp/v2/templates).
@immutable
final class Template implements ISelfRespresentive {
  const Template({
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
    this.isCustom,
  });

  /// Creates a Template from JSON returned by the REST API.
  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
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
      isCustom: castOrElse(json['is_custom']),
      self: json,
    );
  }

  /// Attempts to normalize the template content into a single string value.
  ///
  /// The Templates endpoints may return content as a plain string or as an
  /// object (commonly with `raw`/`rendered`). We prefer `raw` when present,
  /// otherwise fall back to `rendered` and lastly to a direct string.
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

  /// A unique identifier for the template (string identifier used by REST).
  final String id;

  /// Unique slug identifying the template.
  final String slug;

  /// Theme identifier for the template.
  final String theme;

  /// Type of template.
  final String type;

  /// Source of template (read-only).
  final String? source;

  /// Source of a customized template (read-only).
  final String? origin;

  /// Content of template (normalized to a string if object is returned).
  final String? content;

  /// Title of template.
  final Content? title;

  /// Description of template.
  final String? description;

  /// Status of template.
  final ContentStatus status;

  /// Post ID backing this template (read-only).
  final int wpId;

  /// Whether a corresponding theme file exists (read-only).
  final bool hasThemeFile;

  /// The ID for the author of the template.
  final int? author;

  /// The date the template was last modified.
  final DateTime? modified;

  /// Whether a template is a custom template (read-only).
  final bool? isCustom;

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
        'is_custom': isCustom,
      };

  @override
  bool operator ==(covariant Template other) {
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
        other.isCustom == isCustom &&
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
      (isCustom?.hashCode ?? 0) ^
      self.hashCode;
}
