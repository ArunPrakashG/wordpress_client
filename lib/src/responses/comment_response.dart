import 'dart:convert';

import '../enums.dart';
import '../utilities/serializable_instance.dart';
import 'partial_responses/content.dart';
import 'partial_responses/links.dart';

class Comment extends ISerializable<Comment> {
  Comment({
    this.id,
    this.post,
    this.parent,
    this.author,
    this.authorName,
    this.authorUrl,
    this.date,
    this.authorEmail,
    this.authorIp,
    this.authorUserAgent,
    this.dateGmt,
    this.content,
    this.link,
    this.status,
    this.type,
    this.authorAvatarUrls,
    this.meta,
    this.links,
  });

  final int? id;
  final int? post;
  final int? parent;
  final int? author;
  final String? authorName;
  final String? authorEmail;
  final String? authorUrl;
  final String? authorIp;
  final String? authorUserAgent;
  final DateTime? date;
  final DateTime? dateGmt;
  final Content? content;
  final String? link;
  final CommentStatus? status;
  final Type? type;
  final Map<String, String>? authorAvatarUrls;
  final List<dynamic>? meta;
  final Links? links;

  factory Comment.fromJson(String str) => Comment.fromMap(json.decode(str));

  factory Comment.fromMap(Map<String, dynamic> json) => Comment(
        id: json["id"] == null ? null : json["id"],
        post: json["post"] == null ? null : json["post"],
        parent: json["parent"] == null ? null : json["parent"],
        author: json["author"] == null ? null : json["author"],
        authorName: json["author_name"] == null ? null : json["author_name"],
        authorEmail: json["author_email"] == null ? null : json["author_email"],
        authorUrl: json["author_url"] == null ? null : json["author_url"],
        authorIp: json["author_ip"] == null ? null : json["author_ip"],
        authorUserAgent: json["author_user_agent"] == null ? null : json["author_user_agent"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        dateGmt: json["date_gmt"] == null ? null : DateTime.parse(json["date_gmt"]),
        content: json["content"] == null ? null : Content.fromMap(json["content"]),
        link: json["link"] == null ? null : json["link"],
        status: json["status"] == null ? null : getCommentStatusFromValue(json["status"]),
        type: json["type"] == null ? null : json["type"],
        authorAvatarUrls:
            json["author_avatar_urls"] == null ? null : Map.from(json["author_avatar_urls"]).map((k, v) => MapEntry<String, String>(k, v)),
        meta: json["meta"] == null ? null : List<dynamic>.from(json["meta"].map((x) => x)),
        links: json["_links"] == null ? null : Links.fromMap(json["_links"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "post": post == null ? null : post,
        "parent": parent == null ? null : parent,
        "author": author == null ? null : author,
        "author_name": authorName == null ? null : authorName,
        "author_email": authorEmail == null ? null : authorEmail,
        "author_url": authorUrl == null ? null : authorUrl,
        "author_ip": authorIp == null ? null : authorIp,
        "author_user_agent": authorUserAgent == null ? null : authorUserAgent,
        "date": date == null ? null : date!.toIso8601String(),
        "date_gmt": dateGmt == null ? null : dateGmt!.toIso8601String(),
        "content": content == null ? null : content!.toMap(),
        "link": link == null ? null : link,
        "status": status == null ? null : status.toString().split('.').last.toLowerCase(),
        "type": type == null ? null : type,
        "author_avatar_urls": authorAvatarUrls == null ? null : Map.from(authorAvatarUrls!).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "meta": meta == null ? null : List<dynamic>.from(meta!.map((x) => x)),
        "_links": links == null ? null : links!.toMap(),
      };

  @override
  Comment fromJson(Map<String, dynamic>? json) => Comment.fromMap(json!);

  @override
  Map<String, dynamic> toJson() => toMap();
}
