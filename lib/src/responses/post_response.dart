import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/author_meta.dart';
import 'properties/content.dart';

/// Represents a WordPress post.
///
/// This class encapsulates all the properties of a post as defined in the
/// WordPress REST API. For more details, see:
/// https://developer.wordpress.org/rest-api/reference/posts/
@immutable
class Post implements ISelfRespresentive {
  /// Creates a new [Post] instance.
  const Post({
    required this.id,
    required this.slug,
    required this.status,
    required this.link,
    required this.author,
    required this.commentStatus,
    required this.pingStatus,
    required this.format,
    required this.self,
    this.sticky = false,
    this.date,
    this.dateGmt,
    this.password,
    this.guid,
    this.modified,
    this.modifiedGmt,
    this.type,
    this.title,
    this.content,
    this.excerpt,
    this.featuredMedia,
    this.template,
    this.categories,
    this.tags,
    this.featuredImageUrl,
    this.authorMeta,
    this.meta,
    this.permalinkTemplate,
    this.generatedSlug,
  });

  /// Creates a [Post] instance from a JSON map.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: castOrElse(json['id']),
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      guid: castOrElse(
        json['guid'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      password: castOrElse(json['password']),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      modifiedGmt: parseDateIfNotNull(castOrElse(json['modified_gmt'])),
      slug: castOrElse(json['slug'], orElse: () => '')!,
      status: getContentStatusFromValue(castOrElse(json['status'])),
      type: castOrElse(json['type']),
      link: castOrElse(json['link'], orElse: () => '')!,
      title: castOrElse(
        json['title'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      content: castOrElse(
        json['content'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      excerpt: castOrElse(
        json['excerpt'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      author: castOrElse(json['author'], orElse: () => 0)!,
      featuredMedia: castOrElse(json['featured_media']),
      commentStatus: getStatusFromValue(castOrElse(json['comment_status'])),
      pingStatus: getStatusFromValue(castOrElse(json['ping_status'])),
      sticky: castOrElse(json['sticky'], orElse: () => false)!,
      template: castOrElse(json['template']),
      format: getFormatFromValue(castOrElse(json['format'])),
      permalinkTemplate: castOrElse(json['permalink_template']),
      generatedSlug: castOrElse(json['generated_slug']),
      meta: castOrElse(json['meta']),
      categories: mapIterableWithChecks<int>(
        json['categories'],
        (dynamic v) => v as int,
      ),
      tags: mapIterableWithChecks<int>(json['tags'], (dynamic v) => v as int),
      authorMeta: castOrElse(
        json['author_meta'],
        transformer: (value) {
          return AuthorMeta.fromJson(value as Map<String, dynamic>);
        },
      ),
      featuredImageUrl: decodeByMultiKeys(
        json,
        ['featured_image_url', 'featured_media_src_url'],
      ),
      self: json,
    );
  }

  /// The unique identifier for the post.
  final int id;

  /// The date the post was published, in the site's timezone.
  final DateTime? date;

  /// The date the post was published, as GMT.
  final DateTime? dateGmt;

  /// The globally unique identifier for the post.
  final Content? guid;

  /// A password to protect access to the content and excerpt.
  final String? password;

  /// The date the post was last modified, in the site's timezone.
  final DateTime? modified;

  /// The date the post was last modified, as GMT.
  final DateTime? modifiedGmt;

  /// An alphanumeric identifier for the post unique to its type.
  final String slug;

  /// A named status for the post.
  final ContentStatus status;

  /// Type of post.
  final String? type;

  /// URL to the post.
  final String link;

  /// The title for the post.
  final Content? title;

  /// The content for the post.
  final Content? content;

  /// The excerpt for the post.
  final Content? excerpt;

  /// The ID for the author of the post.
  final int author;

  /// The ID of the featured media for the post.
  final int? featuredMedia;

  /// Whether or not comments are open on the post.
  final Status commentStatus;

  /// Whether or not the post can accept pings.
  final Status pingStatus;

  /// Whether or not the post should be treated as sticky.
  final bool sticky;

  /// The theme file to use to display the post.
  final String? template;

  /// The format for the post.
  final PostFormat format;

  /// Permalink template for the post (context: edit).
  final String? permalinkTemplate;

  /// Slug automatically generated from the post title (context: edit).
  final String? generatedSlug;

  /// The terms assigned to the post in the category taxonomy.
  final List<int>? categories;

  /// The terms assigned to the post in the tag taxonomy.
  final List<int>? tags;

  /// Field generated by https://wordpress.org/plugins/rest-api-featured-image/ plugin
  final String? featuredImageUrl;

  /// Field generated by https://wordpress.org/plugins/wp-rest-api-user-meta/
  final AuthorMeta? authorMeta;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  @override
  final Map<String, dynamic> self;

  /// Converts the [Post] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date?.toIso8601String(),
      'date_gmt': dateGmt?.toIso8601String(),
      'guid': guid?.toJson(),
      'password': password,
      'modified': modified?.toIso8601String(),
      'modified_gmt': modifiedGmt?.toIso8601String(),
      'slug': slug,
      'status': status.name,
      'type': type,
      'link': link,
      'title': title?.toJson(),
      'content': content?.toJson(),
      'excerpt': excerpt?.toJson(),
      'author': author,
      'featured_media': featuredMedia,
      'comment_status': commentStatus.name,
      'ping_status': pingStatus.name,
      'sticky': sticky,
      'template': template,
      'permalink_template': permalinkTemplate,
      'generated_slug': generatedSlug,
      'meta': meta,
      'featured_image_url': featuredImageUrl,
      'author_meta': authorMeta?.toJson(),
      'format': format.name,
      'categories': categories,
      'tags': tags,
    };
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) {
      return true;
    }

    final collectionEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.date == date &&
        other.dateGmt == dateGmt &&
        other.guid == guid &&
        other.password == password &&
        other.modified == modified &&
        other.modifiedGmt == modifiedGmt &&
        other.slug == slug &&
        other.status == status &&
        other.type == type &&
        other.link == link &&
        other.title == title &&
        other.content == content &&
        other.excerpt == excerpt &&
        other.author == author &&
        other.featuredMedia == featuredMedia &&
        other.commentStatus == commentStatus &&
        other.pingStatus == pingStatus &&
        other.sticky == sticky &&
        other.template == template &&
        other.permalinkTemplate == permalinkTemplate &&
        other.generatedSlug == generatedSlug &&
        collectionEquals(other.meta, meta) &&
        other.format == format &&
        collectionEquals(other.categories, categories) &&
        collectionEquals(other.tags, tags) &&
        other.featuredImageUrl == featuredImageUrl &&
        other.authorMeta == authorMeta &&
        collectionEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        dateGmt.hashCode ^
        guid.hashCode ^
        password.hashCode ^
        modified.hashCode ^
        modifiedGmt.hashCode ^
        slug.hashCode ^
        status.hashCode ^
        type.hashCode ^
        link.hashCode ^
        title.hashCode ^
        content.hashCode ^
        excerpt.hashCode ^
        author.hashCode ^
        featuredMedia.hashCode ^
        commentStatus.hashCode ^
        pingStatus.hashCode ^
        sticky.hashCode ^
        template.hashCode ^
        permalinkTemplate.hashCode ^
        generatedSlug.hashCode ^
        meta.hashCode ^
        format.hashCode ^
        categories.hashCode ^
        tags.hashCode ^
        featuredImageUrl.hashCode ^
        authorMeta.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Post(id: $id, date: $date, dateGmt: $dateGmt, guid: $guid, password: $password, modified: $modified, modifiedGmt: $modifiedGmt, slug: $slug, status: $status, type: $type, link: $link, title: $title, content: $content, excerpt: $excerpt, author: $author, featuredMedia: $featuredMedia, commentStatus: $commentStatus, pingStatus: $pingStatus, sticky: $sticky, template: $template, permalinkTemplate: $permalinkTemplate, generatedSlug: $generatedSlug, meta: $meta, format: $format, categories: $categories, tags: $tags, featuredImageUrl: $featuredImageUrl, authorMeta: $authorMeta, self: $self)';
  }
}
