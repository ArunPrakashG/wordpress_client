// ignore_for_file: unnecessary_lambdas

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';
import 'link_container.dart';

/// Represents the links associated with a WordPress REST API response.
///
/// The `Links` class encapsulates various types of links that can be present in
/// a WordPress REST API response. These links provide navigation and relation
/// information for the current resource.
///
/// For more information, see the WordPress REST API Handbook:
/// https://developer.wordpress.org/rest-api/reference/
@immutable
final class Links {
  /// Creates a new [Links] instance.
  ///
  /// All parameters are optional and can be null.
  const Links({
    this.self,
    this.collection,
    this.about,
    this.author,
    this.replies,
    this.versionHistory,
    this.predecessorVersion,
    this.wpFeaturedmedia,
    this.wpAttachment,
    this.wpTerm,
    this.curies,
  });

  /// Creates a [Links] instance from a JSON map.
  ///
  /// This factory constructor parses the JSON map and creates the corresponding
  /// [LinkContainer] objects for each link type.
  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      self: mapIterableWithChecks<LinkContainer>(
        json['self'],
        (json) => LinkContainer.fromJson(json),
      ),
      collection: mapIterableWithChecks<LinkContainer>(
        json['collection'],
        (json) => LinkContainer.fromJson(json),
      ),
      about: mapIterableWithChecks<LinkContainer>(
        json['about'],
        (json) => LinkContainer.fromJson(json),
      ),
      author: mapIterableWithChecks<LinkContainer>(
        json['author'],
        (json) => LinkContainer.fromJson(json),
      ),
      replies: mapIterableWithChecks<LinkContainer>(
        json['replies'],
        (json) => LinkContainer.fromJson(json),
      ),
      versionHistory: mapIterableWithChecks<LinkContainer>(
        json['version-history'],
        (json) => LinkContainer.fromJson(json),
      ),
      predecessorVersion: mapIterableWithChecks<LinkContainer>(
        json['predecessor-version'],
        (json) => LinkContainer.fromJson(json),
      ),
      wpFeaturedmedia: mapIterableWithChecks<LinkContainer>(
        json['wp:featuredmedia'],
        (json) => LinkContainer.fromJson(json),
      ),
      wpAttachment: mapIterableWithChecks<LinkContainer>(
        json['wp:attachment'],
        (json) => LinkContainer.fromJson(json),
      ),
      wpTerm: mapIterableWithChecks<LinkContainer>(
        json['wp:term'],
        (json) => LinkContainer.fromJson(json),
      ),
      curies: mapIterableWithChecks<LinkContainer>(
        json['curies'],
        (json) => LinkContainer.fromJson(json),
      ),
    );
  }

  /// The link to the resource itself.
  final List<LinkContainer>? self;

  /// The link to the collection containing the resource.
  final List<LinkContainer>? collection;

  /// The link to the resource's description.
  final List<LinkContainer>? about;

  /// The link to the author of the resource.
  final List<LinkContainer>? author;

  /// The link to the comments or replies for the resource.
  final List<LinkContainer>? replies;

  /// The link to the version history of the resource.
  final List<LinkContainer>? versionHistory;

  /// The link to the previous version of the resource.
  final List<LinkContainer>? predecessorVersion;

  /// The link to the featured media (usually an image) for the resource.
  final List<LinkContainer>? wpFeaturedmedia;

  /// The link to attachments associated with the resource.
  final List<LinkContainer>? wpAttachment;

  /// The link to terms (categories, tags, etc.) associated with the resource.
  final List<LinkContainer>? wpTerm;

  /// CURIE links, which are compact URI expressions for link relations.
  final List<LinkContainer>? curies;

  /// Converts the [Links] instance to a JSON map.
  ///
  /// This method is useful for serializing the object, for example when sending
  /// data to an API or storing it in a database.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'self': self?.map((e) => e.toMap()).toList(),
      'collection': collection?.map((e) => e.toMap()).toList(),
      'about': about?.map((e) => e.toMap()).toList(),
      'author': author?.map((e) => e.toMap()).toList(),
      'replies': replies?.map((e) => e.toMap()).toList(),
      'version-history': versionHistory?.map((e) => e.toMap()).toList(),
      'predecessor-version': predecessorVersion?.map((e) => e.toMap()).toList(),
      'wp:featuredmedia': wpFeaturedmedia?.map((e) => e.toMap()).toList(),
      'wp:attachment': wpAttachment?.map((e) => e.toMap()).toList(),
      'wp:term': wpTerm?.map((e) => e.toMap()).toList(),
      'curies': curies?.map((e) => e.toMap()).toList(),
    };
  }

  /// Compares this [Links] instance to another object for equality.
  ///
  /// Two [Links] instances are considered equal if all their properties are equal.
  @override
  bool operator ==(covariant Links other) {
    if (identical(this, other)) {
      return true;
    }

    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.self, self) &&
        listEquals(other.collection, collection) &&
        listEquals(other.about, about) &&
        listEquals(other.author, author) &&
        listEquals(other.replies, replies) &&
        listEquals(other.versionHistory, versionHistory) &&
        listEquals(other.predecessorVersion, predecessorVersion) &&
        listEquals(other.wpFeaturedmedia, wpFeaturedmedia) &&
        listEquals(other.wpAttachment, wpAttachment) &&
        listEquals(other.wpTerm, wpTerm) &&
        listEquals(other.curies, curies);
  }

  /// Generates a hash code for this [Links] instance.
  ///
  /// The hash code is based on all properties of the instance.
  @override
  int get hashCode {
    return self.hashCode ^
        collection.hashCode ^
        about.hashCode ^
        author.hashCode ^
        replies.hashCode ^
        versionHistory.hashCode ^
        predecessorVersion.hashCode ^
        wpFeaturedmedia.hashCode ^
        wpAttachment.hashCode ^
        wpTerm.hashCode ^
        curies.hashCode;
  }

  /// Returns a string representation of the [Links] instance.
  ///
  /// This method is useful for debugging and logging purposes.
  @override
  String toString() {
    return 'Links(self: $self, collection: $collection, about: $about, author: $author, replies: $replies, versionHistory: $versionHistory, predecessorVersion: $predecessorVersion, wpFeaturedmedia: $wpFeaturedmedia, wpAttachment: $wpAttachment, wpTerm: $wpTerm, curies: $curies)';
  }
}
