import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/avatar_urls.dart';
import 'properties/content.dart';

/// Represents a comment in the WordPress system.
///
/// This class encapsulates all the properties of a comment as defined in the WordPress REST API.
/// For more details, see: https://developer.wordpress.org/rest-api/reference/comments/
@immutable
final class Comment implements ISelfRespresentive {
  /// Creates a new [Comment] instance.
  ///
  /// All parameters correspond to the properties of a comment as defined in the WordPress REST API.
  const Comment({
    required this.self,
    required this.status,
    required this.id,
    required this.authorUrl,
    required this.link,
    required this.type,
    this.post,
    this.parent,
    this.author,
    this.authorName,
    this.date,
    this.authorEmail,
    this.authorIp,
    this.authorUserAgent,
    this.dateGmt,
    this.content,
    this.authorAvatarUrls,
    this.meta,
  });

  /// Creates a [Comment] instance from a JSON map.
  ///
  /// [json] is the JSON map containing the comment data.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: castOrElse(json['id']),
      post: castOrElse(json['post']),
      parent: castOrElse(json['parent']),
      author: castOrElse(json['author']),
      authorName: castOrElse(json['author_name']),
      authorEmail: castOrElse(json['author_email']),
      authorUrl: castOrElse(json['author_url'], orElse: () => '')!,
      authorIp: castOrElse(json['author_ip']),
      authorUserAgent: castOrElse(json['author_user_agent']),
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      content: castOrElse(
        json['content'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      link: castOrElse(json['link']),
      status: getCommentStatusFromValue(castOrElse(json['status'])),
      type: castOrElse(json['type']),
      authorAvatarUrls: castOrElse(
        json['author_avatar_urls'],
        transformer: (value) {
          return AvatarUrls.fromJson(value as Map<String, dynamic>);
        },
      ),
      meta: castOrElse(json['meta']),
      self: json,
    );
  }

  /// Unique identifier for the comment.
  final int id;

  /// The ID of the associated post.
  final int? post;

  /// The ID of the parent comment (if this is a reply).
  final int? parent;

  /// The ID of the user who authored the comment (if they were logged in).
  final int? author;

  /// Display name of the comment author.
  final String? authorName;

  /// Email address of the comment author.
  final String? authorEmail;

  /// URL provided by the comment author.
  final String authorUrl;

  /// IP address of the comment author.
  final String? authorIp;

  /// User agent of the browser used to submit the comment.
  final String? authorUserAgent;

  /// The date the comment was published, in the site's timezone.
  final DateTime? date;

  /// The date the comment was published, as GMT.
  final DateTime? dateGmt;

  /// The content of the comment.
  final Content? content;

  /// URL to the comment.
  final String link;

  /// Status of the comment (approved, pending, spam).
  final CommentStatus status;

  /// Type of the comment (typically 'comment').
  final String type;

  /// Avatar URLs for the comment author.
  final AvatarUrls? authorAvatarUrls;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  /// The raw JSON representation of this object.
  @override
  final Map<String, dynamic> self;

  /// Converts this [Comment] instance to a JSON map.
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
      'status': status.name,
      'type': type,
      'author_avatar_urls': authorAvatarUrls?.toJson(),
      'meta': meta,
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
        mapEquals(other.meta, meta) &&
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
        self.hashCode;
  }

  @override
  String toString() {
    return 'Comment(id: $id, post: $post, parent: $parent, author: $author, authorName: $authorName, authorEmail: $authorEmail, authorUrl: $authorUrl, authorIp: $authorIp, authorUserAgent: $authorUserAgent, date: $date, dateGmt: $dateGmt, content: $content, link: $link, status: $status, type: $type, authorAvatarUrls: $authorAvatarUrls, meta: $meta, self: $self)';
  }
}
