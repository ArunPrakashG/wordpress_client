import 'dart:convert';

import '../../wordpress_client.dart';
import '../utilities/serializable_instance.dart';
import 'partial_responses/content.dart';
import 'partial_responses/links.dart';
import 'partial_responses/media_details.dart';

class Media implements ISerializable<Media> {
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
    this.yoastHead,
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

  final int id;
  final DateTime date;
  final DateTime dateGmt;
  final Content guid;
  final DateTime modified;
  final DateTime modifiedGmt;
  final String slug;
  final Status status;
  final String type;
  final String link;
  final Content title;
  final int author;
  final Status commentStatus;
  final Status pingStatus;
  final String template;
  final List<dynamic> meta;
  final String yoastHead;
  final Content description;
  final Content caption;
  final String altText;
  final String mediaType;
  final String mimeType;
  final MediaDetails mediaDetails;
  final int post;
  final String sourceUrl;
  final Links links;

  factory Media.fromJson(String str) => Media.fromMap(json.decode(str));

  factory Media.fromMap(Map<String, dynamic> json) => Media(
        id: json["id"] == null ? null : json["id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        dateGmt: json["date_gmt"] == null ? null : DateTime.parse(json["date_gmt"]),
        guid: json["guid"] == null ? null : Content.fromMap(json["guid"]),
        modified: json["modified"] == null ? null : DateTime.parse(json["modified"]),
        modifiedGmt: json["modified_gmt"] == null ? null : DateTime.parse(json["modified_gmt"]),
        slug: json["slug"] == null ? null : json["slug"],
        status: json["status"] == null ? null : getStatusFromValue(json["status"]),
        type: json["type"] == null ? null : json["type"],
        link: json["link"] == null ? null : json["link"],
        title: json["title"] == null ? null : Content.fromMap(json["title"]),
        author: json["author"] == null ? null : json["author"],
        commentStatus: json["comment_status"] == null ? null : getStatusFromValue(json["comment_status"]),
        pingStatus: json["ping_status"] == null ? null : getStatusFromValue(json["ping_status"]),
        template: json["template"] == null ? null : json["template"],
        meta: json["meta"] == null ? null : List<dynamic>.from(json["meta"].map((x) => x)),
        yoastHead: json["yoast_head"] == null ? null : json["yoast_head"],
        description: json["description"] == null ? null : Content.fromMap(json["description"]),
        caption: json["caption"] == null ? null : Content.fromMap(json["caption"]),
        altText: json["alt_text"] == null ? null : json["alt_text"],
        mediaType: json["media_type"] == null ? null : json["media_type"],
        mimeType: json["mime_type"] == null ? null : json["mime_type"],
        mediaDetails: json["media_details"] == null ? null : MediaDetails.fromMap(json["media_details"]),
        post: json["post"] == null ? null : json["post"],
        sourceUrl: json["source_url"] == null ? null : json["source_url"],
        links: json["_links"] == null ? null : Links.fromMap(json["_links"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "date": date == null ? null : date.toIso8601String(),
        "date_gmt": dateGmt == null ? null : dateGmt.toIso8601String(),
        "guid": guid == null ? null : guid.toMap(),
        "modified": modified == null ? null : modified.toIso8601String(),
        "modified_gmt": modifiedGmt == null ? null : modifiedGmt.toIso8601String(),
        "slug": slug == null ? null : slug,
        "status": status == null ? null : status.toString().split('.').last.toLowerCase(),
        "type": type == null ? null : type,
        "link": link == null ? null : link,
        "title": title == null ? null : title.toMap(),
        "author": author == null ? null : author,
        "comment_status": commentStatus == null ? null : commentStatus.toString().split('.').last.toLowerCase(),
        "ping_status": pingStatus == null ? null : pingStatus.toString().split('.').last.toLowerCase(),
        "template": template == null ? null : template,
        "meta": meta == null ? null : List<dynamic>.from(meta.map((x) => x)),
        "yoast_head": yoastHead == null ? null : yoastHead,
        "description": description == null ? null : description.toMap(),
        "caption": caption == null ? null : caption.toMap(),
        "alt_text": altText == null ? null : altText,
        "media_type": mediaType == null ? null : mediaType,
        "mime_type": mimeType == null ? null : mimeType,
        "media_details": mediaDetails == null ? null : mediaDetails.toMap(),
        "post": post == null ? null : post,
        "source_url": sourceUrl == null ? null : sourceUrl,
        "_links": links == null ? null : links.toMap(),
      };

  @override
  Media fromJson(Map<String, dynamic> json) => Media.fromMap(json);

  @override
  Map<String, dynamic> toJson() => toMap();
}
