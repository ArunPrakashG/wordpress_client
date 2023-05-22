import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'response_properties/content.dart';
import 'response_properties/links.dart';
import 'response_properties/media_details.dart';

@immutable
class Media implements ISelfRespresentive {
  const Media({
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
    required this.self,
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
      self: json as Map<String, dynamic>,
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

  @override
  final Map<String, dynamic> self;

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

  @override
  bool operator ==(covariant Media other) {
    if (identical(this, other)) {
      return true;
    }

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
        other.author == author &&
        other.commentStatus == commentStatus &&
        other.pingStatus == pingStatus &&
        other.template == template &&
        other.meta == meta &&
        other.description == description &&
        other.caption == caption &&
        other.altText == altText &&
        other.mediaType == mediaType &&
        other.mimeType == mimeType &&
        other.mediaDetails == mediaDetails &&
        other.post == post &&
        other.sourceUrl == sourceUrl &&
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
        author.hashCode ^
        commentStatus.hashCode ^
        pingStatus.hashCode ^
        template.hashCode ^
        meta.hashCode ^
        description.hashCode ^
        caption.hashCode ^
        altText.hashCode ^
        mediaType.hashCode ^
        mimeType.hashCode ^
        mediaDetails.hashCode ^
        post.hashCode ^
        sourceUrl.hashCode ^
        links.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Media(id: $id, date: $date, dateGmt: $dateGmt, guid: $guid, modified: $modified, modifiedGmt: $modifiedGmt, slug: $slug, status: $status, type: $type, link: $link, title: $title, author: $author, commentStatus: $commentStatus, pingStatus: $pingStatus, template: $template, meta: $meta, description: $description, caption: $caption, altText: $altText, mediaType: $mediaType, mimeType: $mimeType, mediaDetails: $mediaDetails, post: $post, sourceUrl: $sourceUrl, links: $links, self: $self)';
  }
}
