import '../enums.dart';
import '../utilities/helpers.dart';
import 'properties/content.dart';
import 'properties/links.dart';
import 'properties/media_details.dart';

class Media {
  Media({
    this.id,
    this.date,
    this.dateGmt,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.slug,
    this.status,
    this.type,
    this.link,
    this.title,
    this.author,
    this.commentStatus,
    this.pingStatus,
    this.template,
    this.meta,
    this.description,
    this.caption,
    this.altText,
    this.mediaType,
    this.mimeType,
    this.mediaDetails,
    this.post,
    this.sourceUrl,
    this.links,
  });

  factory Media.fromJson(dynamic json) {
    return Media(
      id: json['id'] as int?,
      date: parseDateIfNotNull(json['date']),
      dateGmt: parseDateIfNotNull(json['date_gmt']),
      guid: Content.fromJson(json['guid']),
      modified: parseDateIfNotNull(json['modified']),
      modifiedGmt: parseDateIfNotNull(json['modified_gmt']),
      slug: json['slug'] as String?,
      status: getMediaFilterStatusFromValue(json['status'] as String?),
      type: json['type'] as String?,
      link: json['link'] as String?,
      title: Content.fromJson(json['title']),
      author: json['author'] as int?,
      commentStatus: getStatusFromValue(json['comment_status'] as String?),
      pingStatus: getStatusFromValue(json['ping_status'] as String?),
      template: json['template'] as String?,
      meta: json['meta'],
      description: Content.fromJson(json['description']),
      caption: Content.fromJson(json['caption']),
      altText: json['alt_text'] as String?,
      mediaType: json['media_type'] as String?,
      mimeType: json['mime_type'] as String?,
      mediaDetails: MediaDetails.fromJson(json['media_details']),
      post: json['post'] as int?,
      sourceUrl: json['source_url'] as String?,
      links: Links.fromJson(json['_links']),
    );
  }

  final int? id;
  final DateTime? date;
  final DateTime? dateGmt;
  final Content? guid;
  final DateTime? modified;
  final DateTime? modifiedGmt;
  final String? slug;
  final MediaFilterStatus? status;
  final String? type;
  final String? link;
  final Content? title;
  final int? author;
  final Status? commentStatus;
  final Status? pingStatus;
  final String? template;
  final dynamic meta;
  final Content? description;
  final Content? caption;
  final String? altText;
  final String? mediaType;
  final String? mimeType;
  final MediaDetails? mediaDetails;
  final int? post;
  final String? sourceUrl;
  final Links? links;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date?.toIso8601String(),
      'date_gmt': dateGmt?.toIso8601String(),
      'guid': guid?.toJson(),
      'modified': modified?.toIso8601String(),
      'modified_gmt': modifiedGmt?.toIso8601String(),
      'slug': slug,
      'status': status?.name,
      'type': type,
      'link': link,
      'title': title?.toJson(),
      'author': author,
      'comment_status': commentStatus?.name,
      'ping_status': pingStatus?.name,
      'template': template,
      'meta': meta,
      'description': description?.toJson(),
      'caption': caption?.toJson(),
      'alt_text': altText,
      'media_type': mediaType,
      'mime_type': mimeType,
      'media_details': mediaDetails?.toJson(),
      'post': post,
      'source_url': sourceUrl,
      '_links': links?.toJson(),
    };
  }
}
