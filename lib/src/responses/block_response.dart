import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents an Editor Block (wp_block post type).
@immutable
class Block implements ISelfRespresentive {
  const Block({
    required this.id,
    required this.slug,
    required this.status,
    required this.link,
    required this.self,
    this.date,
    this.dateGmt,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.type,
    this.password,
    this.title,
    this.content,
    this.template,
    this.meta,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: castOrElse(json['id'], orElse: () => 0)!,
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      guid: castOrElse(
        json['guid'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      modifiedGmt: parseDateIfNotNull(castOrElse(json['modified_gmt'])),
      slug: castOrElse(json['slug'], orElse: () => '')!,
      status: getContentStatusFromValue(castOrElse(json['status'])),
      type: castOrElse(json['type']),
      password: castOrElse(json['password']),
      link: castOrElse(json['link'], orElse: () => '')!,
      title: castOrElse(
        json['title'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      content: castOrElse(
        json['content'],
        transformer: (v) => Content.fromJson(v as Map<String, dynamic>),
      ),
      template: castOrElse(json['template']),
      meta: castOrElse(json['meta']),
      self: json,
    );
  }

  final int id;
  final DateTime? date;
  final DateTime? dateGmt;
  final Content? guid;
  final DateTime? modified;
  final DateTime? modifiedGmt;
  final String slug;
  final ContentStatus status;
  final String? type;
  final String link;
  final String? password;
  final Content? title;
  final Content? content;
  final String? template;
  final Map<String, dynamic>? meta;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date?.toIso8601String(),
        'date_gmt': dateGmt?.toIso8601String(),
        'guid': guid?.toJson(),
        'modified': modified?.toIso8601String(),
        'modified_gmt': modifiedGmt?.toIso8601String(),
        'slug': slug,
        'status': status.name,
        'type': type,
        'link': link,
        'password': password,
        'title': title?.toJson(),
        'content': content?.toJson(),
        'template': template,
        'meta': meta,
      };
}
