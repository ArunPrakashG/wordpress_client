import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';
import 'link_container.dart';

@immutable
class Links {
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

  factory Links.fromJson(dynamic json) {
    return Links(
      self: mapIterableWithChecks<LinkContainer>(
        json?['self'],
        LinkContainer.fromJson,
      ),
      collection: mapIterableWithChecks<LinkContainer>(
        json?['collection'],
        LinkContainer.fromJson,
      ),
      about: mapIterableWithChecks<LinkContainer>(
        json?['about'],
        LinkContainer.fromJson,
      ),
      author: mapIterableWithChecks<LinkContainer>(
        json?['author'],
        LinkContainer.fromJson,
      ),
      replies: mapIterableWithChecks<LinkContainer>(
        json?['replies'],
        LinkContainer.fromJson,
      ),
      versionHistory: mapIterableWithChecks<LinkContainer>(
        json?['version-history'],
        LinkContainer.fromJson,
      ),
      predecessorVersion: mapIterableWithChecks<LinkContainer>(
        json?['predecessor-version'],
        LinkContainer.fromJson,
      ),
      wpFeaturedmedia: mapIterableWithChecks<LinkContainer>(
        json?['wp:featuredmedia'],
        LinkContainer.fromJson,
      ),
      wpAttachment: mapIterableWithChecks<LinkContainer>(
        json?['wp:attachment'],
        LinkContainer.fromJson,
      ),
      wpTerm: mapIterableWithChecks<LinkContainer>(
        json?['wp:term'],
        LinkContainer.fromJson,
      ),
      curies: mapIterableWithChecks<LinkContainer>(
        json?['curies'],
        LinkContainer.fromJson,
      ),
    );
  }

  final List<LinkContainer>? self;
  final List<LinkContainer>? collection;
  final List<LinkContainer>? about;
  final List<LinkContainer>? author;
  final List<LinkContainer>? replies;
  final List<LinkContainer>? versionHistory;
  final List<LinkContainer>? predecessorVersion;
  final List<LinkContainer>? wpFeaturedmedia;
  final List<LinkContainer>? wpAttachment;
  final List<LinkContainer>? wpTerm;
  final List<LinkContainer>? curies;

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

  @override
  String toString() {
    return 'Links(self: $self, collection: $collection, about: $about, author: $author, replies: $replies, versionHistory: $versionHistory, predecessorVersion: $predecessorVersion, wpFeaturedmedia: $wpFeaturedmedia, wpAttachment: $wpAttachment, wpTerm: $wpTerm, curies: $curies)';
  }
}
