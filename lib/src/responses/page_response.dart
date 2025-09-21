import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../wordpress_client.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents a WordPress page.
///
/// This class encapsulates all the properties of a WordPress page as defined in the
/// WordPress REST API. It provides methods to create, manipulate, and serialize page data.
///
/// For more information, see the WordPress REST API handbook:
/// https://developer.wordpress.org/rest-api/reference/pages/
@immutable
final class Page implements ISelfRespresentive {
  /// Creates a new [Page] instance.
  ///
  /// All parameters correspond to the properties of a WordPress page as defined
  /// in the REST API.
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
    this.excerpt,
    this.featuredMedia,
    this.meta,
    this.permalinkTemplate,
    this.generatedSlug,
  });

  /// Creates a [Page] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize page data received from
  /// the WordPress REST API.
  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: castOrElse(json['id']),
      date: parseDateIfNotNull(castOrElse(json['date'])),
      dateGmt: parseDateIfNotNull(castOrElse(json['date_gmt'])),
      menuOrder: castOrElse(json['menu_order'], orElse: () => 0)!,
      parent: castOrElse(json['parent'], orElse: () => 0)!,
      guid: castOrElse(
        json['guid'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      modified: parseDateIfNotNull(castOrElse(json['modified'])),
      modifiedGmt: parseDateIfNotNull(castOrElse(json['modified_gmt'])),
      slug: castOrElse(json['slug']),
      status: getContentStatusFromValue(castOrElse(json['status'])),
      type: castOrElse(json['type']),
      link: castOrElse(json['link']),
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
      author: castOrElse(json['author']),
      featuredMedia: castOrElse(json['featured_media']),
      commentStatus: getStatusFromValue(castOrElse(json['comment_status'])),
      pingStatus: getStatusFromValue(castOrElse(json['ping_status'])),
      template: castOrElse(json['template']),
      permalinkTemplate: castOrElse(json['permalink_template']),
      generatedSlug: castOrElse(json['generated_slug']),
      meta: castOrElse(json['meta']),
      self: json,
    );
  }

  /// The unique identifier for the page.
  final int id;

  /// The date the page was published, in the site's timezone.
  final DateTime? date;

  /// The date the page was published, as GMT.
  final DateTime? dateGmt;

  /// The globally unique identifier for the page.
  final Content? guid;

  /// The date the page was last modified, in the site's timezone.
  final DateTime? modified;

  /// The date the page was last modified, as GMT.
  final DateTime? modifiedGmt;

  /// An alphanumeric identifier for the page unique to its type.
  final String slug;

  /// A named status for the page.
  final ContentStatus status;

  /// Type of Post for the page.
  final String? type;

  /// URL to the page.
  final String? link;

  /// The title of the page.
  final Content? title;

  /// The content of the page.
  final Content? content;

  /// The excerpt of the page.
  final Content? excerpt;

  /// The ID of the user who published the page.
  final int author;

  /// The ID of the featured media for the page.
  final int? featuredMedia;

  /// Whether or not comments are open on the page.
  final Status commentStatus;

  /// Whether or not the page can be pinged.
  final Status pingStatus;

  /// The theme file to use to display the page.
  final String template;

  /// Permalink template for the page (context: edit).
  final String? permalinkTemplate;

  /// Slug automatically generated from the page title (context: edit).
  final String? generatedSlug;

  /// The ID of the parent page.
  final int parent;

  /// The order of the page in relation to other pages.
  final int menuOrder;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  /// The raw data of the page as received from the API.
  @override
  final Map<String, dynamic> self;

  /// Creates a copy of this [Page] but with the given fields replaced with the new values.
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
      self: self ?? this.self,
    );
  }

  /// Converts this [Page] instance to a JSON map.
  ///
  /// This method is used to serialize the page data for sending to the WordPress REST API.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date?.toIso8601String(),
      'date_gmt': dateGmt?.toIso8601String(),
      'guid': guid?.toJson(),
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
      'template': template,
      'permalink_template': permalinkTemplate,
      'generated_slug': generatedSlug,
      'parent': parent,
      'menu_order': menuOrder,
      'meta': meta,
    };
  }

  @override
  String toString() {
    return 'Page(id: $id, date: $date, dateGmt: $dateGmt, guid: $guid, modified: $modified, modifiedGmt: $modifiedGmt, slug: $slug, status: $status, type: $type, link: $link, title: $title, content: $content, excerpt: $excerpt, author: $author, featuredMedia: $featuredMedia, commentStatus: $commentStatus, pingStatus: $pingStatus, template: $template, permalinkTemplate: $permalinkTemplate, generatedSlug: $generatedSlug, parent: $parent, menuOrder: $menuOrder, meta: $meta, self: $self)';
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
        other.excerpt == excerpt &&
        other.author == author &&
        other.featuredMedia == featuredMedia &&
        other.commentStatus == commentStatus &&
        other.pingStatus == pingStatus &&
        other.template == template &&
        other.permalinkTemplate == permalinkTemplate &&
        other.generatedSlug == generatedSlug &&
        other.parent == parent &&
        other.menuOrder == menuOrder &&
        mapEquals(other.meta, meta) &&
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
        excerpt.hashCode ^
        author.hashCode ^
        featuredMedia.hashCode ^
        commentStatus.hashCode ^
        pingStatus.hashCode ^
        template.hashCode ^
        permalinkTemplate.hashCode ^
        generatedSlug.hashCode ^
        parent.hashCode ^
        menuOrder.hashCode ^
        meta.hashCode ^
        self.hashCode;
  }
}
