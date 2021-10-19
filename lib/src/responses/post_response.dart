import 'dart:convert';

import '../enums.dart';
import '../utilities/serializable_instance.dart';
import 'partial_responses/content.dart';
import 'partial_responses/links.dart';

class Post implements ISerializable<Post> {
  Post({
    this.id,
    this.date,
    this.dateGmt,
    this.password,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.slug,
    this.status,
    this.type,
    this.link,
    this.title,
    this.content,
    this.excerpt,
    this.author,
    this.featuredMedia,
    this.commentStatus,
    this.pingStatus,
    this.sticky,
    this.template,
    this.format,
    this.meta,
    this.categories,
    this.tags,
    this.links,
    this.yoastHead,
  });

  final int? id;
  final DateTime? date;
  final DateTime? dateGmt;
  final Content? guid;
  final String? password;
  final DateTime? modified;
  final DateTime? modifiedGmt;
  final String? slug;
  final ContentStatus? status;
  final String? type;
  final String? link;
  final Content? title;
  final Content? content;
  final Content? excerpt;
  final int? author;
  final int? featuredMedia;
  final Status? commentStatus;
  final Status? pingStatus;
  final bool? sticky;
  final String? template;
  final PostFormat? format;
  final List<dynamic>? meta;
  final List<int>? categories;
  final List<int>? tags;
  final String? yoastHead;
  final Links? links;

  factory Post.fromJson(String str) => Post.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Post.fromMap(Map<String, dynamic> json) => Post(
        id: json['id'] ?? -1,
        date: json['date'] == null ? null : DateTime.parse(json['date']),
        dateGmt: json['date_gmt'] == null ? null : DateTime.parse(json['date_gmt']),
        guid: json['guid'] == null ? null : Content.fromMap(json['guid']),
        password: json["password"] == null ? null : json["password"],
        modified: json['modified'] == null ? null : DateTime.parse(json['modified']),
        modifiedGmt: json['modified_gmt'] == null ? null : DateTime.parse(json['modified_gmt']),
        slug: json['slug'] ?? '',
        status: getContentStatusFromValue(json['status']),
        type: json['type'] ?? '',
        link: json['link'] ?? '',
        title: json['title'] == null ? null : Content.fromMap(json['title']),
        content: json['content'] == null ? null : Content.fromMap(json['content']),
        excerpt: json['excerpt'] == null ? null : Content.fromMap(json['excerpt']),
        author: json['author'] ?? '' as int?,
        featuredMedia: json['featured_media'] ?? '' as int?,
        commentStatus: getStatusFromValue(json['comment_status']),
        pingStatus: getStatusFromValue(json['ping_status']),
        sticky: json['sticky'] ?? false,
        template: json['template'] ?? '',
        format: getFormatFromValue(json['format']),
        meta: json['meta'] == null ? null : List<dynamic>.from(json['meta'].map((x) => x)),
        categories: json['categories'] == null ? null : List<int>.from(json['categories'].map((x) => x)),
        tags: json['tags'] == null ? null : List<int>.from(json['tags'].map((x) => x)),
        yoastHead: json['yoast_head'] ?? '',
        links: json['_links'] == null ? null : Links.fromMap(json['_links']),
      );

  Map<String, dynamic> toMap() => {
        'id': id ?? -1,
        'date': date == null ? null : date!.toIso8601String(),
        'date_gmt': dateGmt == null ? null : dateGmt!.toIso8601String(),
        'guid': guid == null ? null : guid!.toMap(),
        'password': password,
        'modified': modified == null ? null : modified!.toIso8601String(),
        'modified_gmt': modifiedGmt == null ? null : modifiedGmt!.toIso8601String(),
        'slug': slug ?? '',
        'status': status.toString().split('.').last,
        'type': type ?? type.toString().split('.').last,
        'link': link ?? '',
        'title': title == null ? null : title!.toMap(),
        'content': content == null ? null : content!.toMap(),
        'excerpt': excerpt == null ? null : excerpt!.toMap(),
        'author': author ?? '',
        'featured_media': featuredMedia ?? '',
        'comment_status': commentStatus.toString().split('.').last,
        'ping_status': pingStatus.toString().split('.').last,
        'sticky': sticky ?? false,
        'template': template ?? '',
        'format': format.toString().split('.').last,
        'meta': meta == null ? null : List<dynamic>.from(meta!.map((x) => x)),
        'categories': categories == null ? null : List<dynamic>.from(categories!.map((x) => x)),
        'tags': tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
        'yoast_head': yoastHead ?? '',
        '_links': links == null ? null : links!.toMap(),
      };

  @override
  Post fromJson(Map<String, dynamic>? json) => Post.fromMap(json!);
}
