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
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      collection: mapIterableWithChecks<LinkContainer>(
        json['collection'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      about: mapIterableWithChecks<LinkContainer>(
        json['about'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      author: mapIterableWithChecks<LinkContainer>(
        json['author'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      replies: mapIterableWithChecks<LinkContainer>(
        json['replies'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      versionHistory: mapIterableWithChecks<LinkContainer>(
        json['version-history'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      predecessorVersion: mapIterableWithChecks<LinkContainer>(
        json['predecessor-version'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      wpFeaturedmedia: mapIterableWithChecks<LinkContainer>(
        json['wp:featuredmedia'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      wpAttachment: mapIterableWithChecks<LinkContainer>(
        json['wp:attachment'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      wpTerm: mapIterableWithChecks<LinkContainer>(
        json['wp:term'],
        (dynamic v) => LinkContainer.fromJson(v),
      ),
      curies: mapIterableWithChecks<LinkContainer>(
        json['curies'],
        (dynamic v) => LinkContainer.fromJson(v),
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
