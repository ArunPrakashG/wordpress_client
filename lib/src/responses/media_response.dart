import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../enums.dart';
import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';
import 'properties/media_details.dart';

/// Represents a media item in the WordPress system.
///
/// This class encapsulates all the properties of a media item as defined in the WordPress REST API.
/// Media items are attachments, such as images, documents, or videos.
///
/// For more details, see: https://developer.wordpress.org/rest-api/reference/media/
@immutable
final class Media implements ISelfRespresentive {
  /// Creates a new [Media] instance.
  ///
  /// All parameters correspond to the properties of a media item as defined in the WordPress REST API.
  const Media({
    required this.self,
    required this.id,
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
    this.permalinkTemplate,
    this.generatedSlug,
    this.missingImageSizes,
  });

  /// Creates a [Media] instance from a JSON map.
  ///
  /// [json] is the JSON map containing the media item data.
  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: castOrElse(json['id']),
      date: parseDateIfNotNull(json['date']),
      dateGmt: parseDateIfNotNull(json['date_gmt']),
      guid: castOrElse(
        json['guid'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      modified: parseDateIfNotNull(json['modified']),
      modifiedGmt: parseDateIfNotNull(json['modified_gmt']),
      slug: castOrElse(json['slug']),
      status: getMediaFilterStatusFromValue(json['status'] as String?),
      type: castOrElse(json['type']),
      link: castOrElse(json['link']),
      title: castOrElse(
        json['title'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      permalinkTemplate: castOrElse(json['permalink_template']),
      generatedSlug: castOrElse(json['generated_slug']),
      author: castOrElse(json['author']),
      commentStatus: getStatusFromValue(json['comment_status'] as String?),
      pingStatus: getStatusFromValue(json['ping_status'] as String?),
      template: castOrElse(json['template']),
      meta: castOrElse(json['meta']),
      description: castOrElse(
        json['description'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      caption: castOrElse(
        json['caption'],
        transformer: (value) => Content.fromJson(value as Map<String, dynamic>),
      ),
      altText: castOrElse(json['alt_text']),
      mediaType: castOrElse(json['media_type']),
      mimeType: castOrElse(json['mime_type']),
      mediaDetails: castOrElse(
        json['media_details'],
        transformer: (value) {
          return MediaDetails.fromJson(value as Map<String, dynamic>);
        },
      ),
      post: castOrElse(json['post']),
      sourceUrl: castOrElse(json['source_url']),
      missingImageSizes: mapIterableWithChecks<String>(
        json['missing_image_sizes'],
        (dynamic v) => v as String,
      ),
      self: json,
    );
  }

  /// Unique identifier for the media item.
  final int id;

  /// The date the media item was created, in the site's timezone.
  final DateTime? date;

  /// The date the media item was created, as GMT.
  final DateTime? dateGmt;

  /// The globally unique identifier for the media item.
  final Content? guid;

  /// The date the media item was last modified, in the site's timezone.
  final DateTime? modified;

  /// The date the media item was last modified, as GMT.
  final DateTime? modifiedGmt;

  /// An alphanumeric identifier for the media item unique to its type.
  final String? slug;

  /// The current status of the media item.
  final MediaFilterStatus? status;

  /// Type of media item.
  final String? type;

  /// URL to the media item.
  final String? link;

  /// Permalink template for the media (context: edit).
  final String? permalinkTemplate;

  /// Slug automatically generated from the title (context: edit).
  final String? generatedSlug;

  /// The title of the media item.
  final Content? title;

  /// The ID of the user who uploaded the media item.
  final int? author;

  /// Whether or not comments are open on the media item.
  final Status? commentStatus;

  /// Whether or not the media item can be pinged.
  final Status? pingStatus;

  /// The theme file to use to display the media item.
  final String? template;

  /// Meta fields associated with the media item.
  final dynamic meta;

  /// The description of the media item.
  final Content? description;

  /// The caption for the media item.
  final Content? caption;

  /// The alternative text for the media item.
  final String? altText;

  /// The media type of the media item.
  final String? mediaType;

  /// The MIME type of the media item.
  final String? mimeType;

  /// Details about the media file, specific to its type.
  final MediaDetails? mediaDetails;

  /// The ID of the associated post of the media item.
  final int? post;

  /// The source URL of the media item.
  final String? sourceUrl;

  /// List of missing image sizes (context: edit).
  final List<String>? missingImageSizes;

  /// The raw JSON representation of this object.
  @override
  final Map<String, dynamic> self;

  /// Converts this [Media] instance to a JSON map.
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
      'permalink_template': permalinkTemplate,
      'generated_slug': generatedSlug,
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
      'missing_image_sizes': missingImageSizes,
    };
  }

  @override
  bool operator ==(covariant Media other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;
    final collectionEquals = const DeepCollectionEquality().equals;

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
        other.permalinkTemplate == permalinkTemplate &&
        other.generatedSlug == generatedSlug &&
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
        collectionEquals(other.missingImageSizes, missingImageSizes) &&
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
        permalinkTemplate.hashCode ^
        generatedSlug.hashCode ^
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
        missingImageSizes.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Media(id: $id, date: $date, dateGmt: $dateGmt, guid: $guid, modified: $modified, modifiedGmt: $modifiedGmt, slug: $slug, status: $status, type: $type, link: $link, title: $title, author: $author, commentStatus: $commentStatus, pingStatus: $pingStatus, template: $template, meta: $meta, description: $description, caption: $caption, altText: $altText, mediaType: $mediaType, mimeType: $mimeType, mediaDetails: $mediaDetails, post: $post, sourceUrl: $sourceUrl, self: $self)';
  }
}
