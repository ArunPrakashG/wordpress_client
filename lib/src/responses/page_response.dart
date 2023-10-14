import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';
import 'properties/links.dart';

@immutable
final class Page implements ISelfRespresentive {
  const Page({
    required this.id,
    required this.slug,
    required this.status,
    required this.author,
    required this.commentStatus,
    required this.pingStatus,
    required this.template,
    required this.parent,
    required this.menuOrder,
    required this.meta,
    required this.self,
    this.date,
    this.dateGmt,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.type,
    this.link,
    this.title,
    this.content,
    this.featuredMedia,
    this.links,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: castOrElse(json['id']),
      date: castOrElse(
        json['date'],
        transformer: parseDateIfNotNull,
      ),
      dateGmt: castOrElse(
        json['date_gmt'],
        transformer: parseDateIfNotNull,
      ),
      menuOrder: castOrElse(json['menu_order'], orElse: () => 0)!,
      parent: castOrElse(json['parent'], orElse: () => 0)!,
      guid: Content.fromJson(json['guid']),
      modified: castOrElse(json['modified'], transformer: parseDateIfNotNull),
      modifiedGmt: castOrElse(
        json['modified_gmt'],
        transformer: parseDateIfNotNull,
      ),
      slug: castOrElse(json['slug']),
      status: castOrElse(
        json['status'],
        transformer: (value) => getContentStatusFromValue(value as String?),
        orElse: () => ContentStatus.pending,
      )!,
      type: castOrElse(json['type']),
      link: castOrElse(json['link']),
      title: Content.fromJson(json['title']),
      content: Content.fromJson(json['content']),
      author: castOrElse(json['author']),
      featuredMedia: castOrElse(json['featured_media']),
      commentStatus: getStatusFromValue(json['comment_status'] as String?),
      pingStatus: getStatusFromValue(json['ping_status'] as String?),
      template: castOrElse(json['template']),
      meta: json['meta'],
      links: Links.fromJson(json['_links']),
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
  final String? link;
  final Content? title;
  final Content? content;
  final int author;
  final int? featuredMedia;
  final Status commentStatus;
  final Status pingStatus;
  final String template;
  final int parent;
  final int menuOrder;
  final dynamic meta;
  final Links? links;

  @override
  final Map<String, dynamic> self;

  Page copyWith({
    int? id,
    DateTime? date,
    DateTime? dateGmt,
    Content? guid,
    DateTime? modified,
    DateTime? modifiedGmt,
    String? slug,
    ContentStatus? status,
    String? type,
    String? link,
    Content? title,
    Content? content,
    int? author,
    int? featuredMedia,
    Status? commentStatus,
    Status? pingStatus,
    String? template,
    int? parent,
    int? menuOrder,
    dynamic meta,
    Links? links,
    Map<String, dynamic>? self,
  }) {
    return Page(
      id: id ?? this.id,
      date: date ?? this.date,
      dateGmt: dateGmt ?? this.dateGmt,
      guid: guid ?? this.guid,
      modified: modified ?? this.modified,
      modifiedGmt: modifiedGmt ?? this.modifiedGmt,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      type: type ?? this.type,
      link: link ?? this.link,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      featuredMedia: featuredMedia ?? this.featuredMedia,
      commentStatus: commentStatus ?? this.commentStatus,
      pingStatus: pingStatus ?? this.pingStatus,
      template: template ?? this.template,
      parent: parent ?? this.parent,
      menuOrder: menuOrder ?? this.menuOrder,
      meta: meta ?? this.meta,
      links: links ?? this.links,
      self: self ?? this.self,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date?.millisecondsSinceEpoch,
      'dateGmt': dateGmt?.millisecondsSinceEpoch,
      'guid': guid?.toJson(),
      'modified': modified?.millisecondsSinceEpoch,
      'modifiedGmt': modifiedGmt?.millisecondsSinceEpoch,
      'slug': slug,
      'status': status.name,
      'type': type,
      'link': link,
      'title': title?.toJson(),
      'content': content?.toJson(),
      'author': author,
      'featuredMedia': featuredMedia,
      'commentStatus': commentStatus.name,
      'pingStatus': pingStatus.name,
      'template': template,
      'parent': parent,
      'menuOrder': menuOrder,
      'meta': meta,
      'links': links?.toJson(),
      'self': self,
    };
  }

  @override
  String toString() {
    return 'Page(id: $id, date: $date, dateGmt: $dateGmt, guid: $guid, modified: $modified, modifiedGmt: $modifiedGmt, slug: $slug, status: $status, type: $type, link: $link, title: $title, content: $content, author: $author, featuredMedia: $featuredMedia, commentStatus: $commentStatus, pingStatus: $pingStatus, template: $template, parent: $parent, menuOrder: $menuOrder, meta: $meta, links: $links, self: $self)';
  }

  @override
  bool operator ==(covariant Page other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.date == date &&
        other.dateGmt == dateGmt &&
        other.guid == guid &&
        other.modified == modified &&
        other.modifiedGmt == modifiedGmt &&
        other.slug == slug &&
        other.status == status &&
        other.type == type &&
        other.link == link &&
        other.title == title &&
        other.content == content &&
        other.author == author &&
        other.featuredMedia == featuredMedia &&
        other.commentStatus == commentStatus &&
        other.pingStatus == pingStatus &&
        other.template == template &&
        other.parent == parent &&
        other.menuOrder == menuOrder &&
        other.meta == meta &&
        other.links == links &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        dateGmt.hashCode ^
        guid.hashCode ^
        modified.hashCode ^
        modifiedGmt.hashCode ^
        slug.hashCode ^
        status.hashCode ^
        type.hashCode ^
        link.hashCode ^
        title.hashCode ^
        content.hashCode ^
        author.hashCode ^
        featuredMedia.hashCode ^
        commentStatus.hashCode ^
        pingStatus.hashCode ^
        template.hashCode ^
        parent.hashCode ^
        menuOrder.hashCode ^
        meta.hashCode ^
        links.hashCode ^
        self.hashCode;
  }
}
