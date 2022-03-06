import '../enums.dart';
import 'response_properties/content.dart';
import 'response_properties/links.dart';

class Comment {
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

  factory Comment.fromJson(dynamic json) {
    return Comment(
      id: json['id'] as int?,
      post: json['post'] as int?,
      parent: json['parent'] as int?,
      author: json['author'] as int?,
      authorName: json['author_name'] as String?,
      authorEmail: json['author_email'] as String?,
      authorUrl: json['author_url'] as String?,
      authorIp: json['author_ip'] as String?,
      authorUserAgent: json['author_user_agent'] as String?,
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      dateGmt: DateTime.tryParse(json['date_gmt'] as String? ?? ''),
      content: Content.fromJson(json['content'] as Map<String, dynamic>?),
      link: json['link'] as String?,
      status: getCommentStatusFromValue(json['status'] as String?),
      type: json['type'] as String?,
      authorAvatarUrls: json['author_avatar_urls'] == null
          ? null
          : Map<String, String>.from(
                  json['author_avatar_urls'] as Map<String, dynamic>)
              .map(MapEntry<String, String>.new),
      meta: json['meta'],
      links: Links.fromJson(json['_links']),
    );
  }

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
  final String? type;
  final Map<String, String>? authorAvatarUrls;
  final dynamic meta;
  final Links? links;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'post': post,
      'parent': parent,
      'author': author,
      'author_name': authorName,
      'author_email': authorEmail,
      'author_url': authorUrl,
      'author_ip': authorIp,
      'author_user_agent': authorUserAgent,
      'date': date?.toIso8601String(),
      'date_gmt': dateGmt?.toIso8601String(),
      'content': content?.toJson(),
      'link': link,
      'status': status?.name,
      'type': type,
      'author_avatar_urls': authorAvatarUrls == null
          ? null
          : Map<String, dynamic>.from(authorAvatarUrls!)
              .map<String, dynamic>(MapEntry<String, dynamic>.new),
      'meta': meta,
      '_links': links?.toJson(),
    };
  }
}
