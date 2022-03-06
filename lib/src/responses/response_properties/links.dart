import '../../utilities/helpers.dart';
import 'link_container.dart';

class Links {
  Links({
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
        json['self'],
        LinkContainer.fromJson,
      ),
      collection: mapIterableWithChecks<LinkContainer>(
        json['collection'],
        LinkContainer.fromJson,
      ),
      about: mapIterableWithChecks<LinkContainer>(
        json['about'],
        LinkContainer.fromJson,
      ),
      author: mapIterableWithChecks<LinkContainer>(
        json['author'],
        LinkContainer.fromJson,
      ),
      replies: mapIterableWithChecks<LinkContainer>(
        json['replies'],
        LinkContainer.fromJson,
      ),
      versionHistory: mapIterableWithChecks<LinkContainer>(
        json['version-history'],
        LinkContainer.fromJson,
      ),
      predecessorVersion: mapIterableWithChecks<LinkContainer>(
        json['predecessor-version'],
        LinkContainer.fromJson,
      ),
      wpFeaturedmedia: mapIterableWithChecks<LinkContainer>(
        json['wp:featuredmedia'],
        LinkContainer.fromJson,
      ),
      wpAttachment: mapIterableWithChecks<LinkContainer>(
        json['wp:attachment'],
        LinkContainer.fromJson,
      ),
      wpTerm: mapIterableWithChecks<LinkContainer>(
        json['wp:term'],
        LinkContainer.fromJson,
      ),
      curies: mapIterableWithChecks<LinkContainer>(
        json['curies'],
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
      'self': self?.map((e) => e.toMap()),
      'collection': collection?.map((e) => e.toMap()),
      'about': about?.map((e) => e.toMap()),
      'author': author?.map((e) => e.toMap()),
      'replies': replies?.map((e) => e.toMap()),
      'version-history': versionHistory?.map((e) => e.toMap()),
      'predecessor-version': predecessorVersion?.map((e) => e.toMap()),
      'wp:featuredmedia': wpFeaturedmedia?.map((e) => e.toMap()),
      'wp:attachment': wpAttachment?.map((e) => e.toMap()),
      'wp:term': wpTerm?.map((e) => e.toMap()),
      'curies': curies?.map((e) => e.toMap()),
    };
  }
}
