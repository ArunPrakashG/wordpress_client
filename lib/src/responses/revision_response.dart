import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a Post/Page revision item.
@immutable
final class Revision implements ISelfRespresentive {
  const Revision({
    required this.id,
    required this.parent,
    required this.author,
    required this.date,
    required this.dateGmt,
    required this.modified,
    required this.modifiedGmt,
    required this.slug,
    required this.type,
    required this.self,
    this.guid,
    this.title,
    this.content,
    this.excerpt,
  });

  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      id: castOrElse(json['id'], orElse: () => 0)!,
      parent: castOrElse(json['parent']),
      author: castOrElse(json['author'], orElse: () => 0)!,
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      modifiedGmt: parseDateIfNotNull(castOrElse(json['modified_gmt'])),
      slug: castOrElse(json['slug'], orElse: () => '')!,
      type: castOrElse(json['type'], orElse: () => '')!,
      guid: castOrElse(
        json['guid'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      title: castOrElse(
        json['title'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      content: castOrElse(
        json['content'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      excerpt: castOrElse(
        json['excerpt'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      self: json,
    );
  }

  final int id;
  final int? parent;
  final int author;
  final DateTime? date;
  final DateTime? dateGmt;
  final DateTime? modified;
  final DateTime? modifiedGmt;
  final String slug;
  final String type;
  final Content? guid;
  final Content? title;
  final Content? content;
  final Content? excerpt;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'parent': parent,
        'author': author,
        'date': date?.toIso8601String(),
        'date_gmt': dateGmt?.toIso8601String(),
        'modified': modified?.toIso8601String(),
        'modified_gmt': modifiedGmt?.toIso8601String(),
        'slug': slug,
        'type': type,
        'guid': guid?.toJson(),
        'title': title?.toJson(),
        'content': content?.toJson(),
        'excerpt': excerpt?.toJson(),
      };

  @override
  bool operator ==(covariant Revision other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.parent == parent &&
        other.author == author &&
        other.date == date &&
        other.dateGmt == dateGmt &&
        other.modified == modified &&
        other.modifiedGmt == modifiedGmt &&
        other.slug == slug &&
        other.type == type &&
        other.guid == guid &&
        other.title == title &&
        other.content == content &&
        other.excerpt == excerpt &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      parent.hashCode ^
      author.hashCode ^
      date.hashCode ^
      dateGmt.hashCode ^
      modified.hashCode ^
      modifiedGmt.hashCode ^
      slug.hashCode ^
      type.hashCode ^
      guid.hashCode ^
      title.hashCode ^
      content.hashCode ^
      excerpt.hashCode ^
      self.hashCode;
}
