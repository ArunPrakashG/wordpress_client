import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'response_properties/content.dart';
import 'response_properties/links.dart';

@immutable
class Comment implements ISelfRespresentive {
  const Comment({
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
    required this.self,
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
      date: parseDateIfNotNull(json['date']),
      dateGmt: parseDateIfNotNull(json['date_gmt']),
      content: Content.fromJson(json['content'] as Map<String, dynamic>?),
      link: json['link'] as String?,
      status: getCommentStatusFromValue(json['status'] as String?),
      type: json['type'] as String?,
      authorAvatarUrls: json['author_avatar_urls'] == null
          ? null
          : Map<String, String>.from(
                  json['author_avatar_urls'] as Map<String, dynamic>)
              .map(MapEntry.new),
      meta: json['meta'],
      links: Links.fromJson(json['_links']),
      self: json as Map<String, dynamic>,
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

  @override
  final Map<String, dynamic> self;

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

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.post == post &&
        other.parent == parent &&
        other.author == author &&
        other.authorName == authorName &&
        other.authorEmail == authorEmail &&
        other.authorUrl == authorUrl &&
        other.authorIp == authorIp &&
        other.authorUserAgent == authorUserAgent &&
        other.date == date &&
        other.dateGmt == dateGmt &&
        other.content == content &&
        other.link == link &&
        other.status == status &&
        other.type == type &&
        mapEquals(other.authorAvatarUrls, authorAvatarUrls) &&
        other.meta == meta &&
        other.links == links &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        post.hashCode ^
        parent.hashCode ^
        author.hashCode ^
        authorName.hashCode ^
        authorEmail.hashCode ^
        authorUrl.hashCode ^
        authorIp.hashCode ^
        authorUserAgent.hashCode ^
        date.hashCode ^
        dateGmt.hashCode ^
        content.hashCode ^
        link.hashCode ^
        status.hashCode ^
        type.hashCode ^
        authorAvatarUrls.hashCode ^
        meta.hashCode ^
        links.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Comment(id: $id, post: $post, parent: $parent, author: $author, authorName: $authorName, authorEmail: $authorEmail, authorUrl: $authorUrl, authorIp: $authorIp, authorUserAgent: $authorUserAgent, date: $date, dateGmt: $dateGmt, content: $content, link: $link, status: $status, type: $type, authorAvatarUrls: $authorAvatarUrls, meta: $meta, links: $links, self: $self)';
  }
}
