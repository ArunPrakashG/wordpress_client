import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a Pattern Directory Item (wp/v2/pattern-directory/patterns).
///
/// See: https://developer.wordpress.org/rest-api/reference/pattern-directory-items/
@immutable
final class PatternDirectoryItem implements ISelfRespresentive {
  const PatternDirectoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.self,
    this.categories,
    this.keywords,
    this.description,
    this.viewportWidth,
    this.blockTypes,
  });

  factory PatternDirectoryItem.fromJson(Map<String, dynamic> json) {
    return PatternDirectoryItem(
      id: castOrElse(json['id']),
      title: castOrElse(json['title']),
      content: castOrElse(json['content']),
      description: castOrElse(json['description']),
      viewportWidth: castOrElse(json['viewport_width']),
      categories: mapIterableWithChecks<String>(
        json['categories'],
        (dynamic v) => v as String,
      ),
      keywords: mapIterableWithChecks<String>(
        json['keywords'],
        (dynamic v) => v as String,
      ),
      blockTypes: mapIterableWithChecks<String>(
        json['block_types'],
        (dynamic v) => v as String,
      ),
      self: json,
    );
  }

  /// The pattern ID.
  final int id;

  /// The pattern title, in human readable format.
  final String title;

  /// The pattern content (block markup).
  final String content;

  /// A description of the pattern.
  final String? description;

  /// The pattern's category slugs.
  final List<String>? categories;

  /// The pattern's keywords.
  final List<String>? keywords;

  /// The preferred width of the viewport when previewing a pattern, in pixels.
  final int? viewportWidth;

  /// The block types which can use this pattern.
  final List<String>? blockTypes;

  @override
  final Map<String, dynamic> self;
}
