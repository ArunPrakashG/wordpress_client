import 'dart:convert';

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

  final List<LinkContainer> self;
  final List<LinkContainer> collection;
  final List<LinkContainer> about;
  final List<LinkContainer> author;
  final List<LinkContainer> replies;
  final List<LinkContainer> versionHistory;
  final List<LinkContainer> predecessorVersion;
  final List<LinkContainer> wpFeaturedmedia;
  final List<LinkContainer> wpAttachment;
  final List<LinkContainer> wpTerm;
  final List<LinkContainer> curies;

  factory Links.fromJson(String str) => Links.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Links.fromMap(Map<String, dynamic> json) => Links(
        self: json['self'] == null ? null : List<LinkContainer>.from(json['self'].map((x) => LinkContainer.fromMap(x))),
        collection: json['collection'] == null ? null : List<LinkContainer>.from(json['collection'].map((x) => LinkContainer.fromMap(x))),
        about: json['about'] == null ? null : List<LinkContainer>.from(json['about'].map((x) => LinkContainer.fromMap(x))),
        author: json['author'] == null ? null : List<LinkContainer>.from(json['author'].map((x) => LinkContainer.fromMap(x))),
        replies: json['replies'] == null ? null : List<LinkContainer>.from(json['replies'].map((x) => LinkContainer.fromMap(x))),
        versionHistory:
            json['version-history'] == null ? null : List<LinkContainer>.from(json['version-history'].map((x) => LinkContainer.fromMap(x))),
        predecessorVersion:
            json['predecessor-version'] == null ? null : List<LinkContainer>.from(json['predecessor-version'].map((x) => LinkContainer.fromMap(x))),
        wpFeaturedmedia:
            json['wp:featuredmedia'] == null ? null : List<LinkContainer>.from(json['wp:featuredmedia'].map((x) => LinkContainer.fromMap(x))),
        wpAttachment: json['wp:attachment'] == null ? null : List<LinkContainer>.from(json['wp:attachment'].map((x) => LinkContainer.fromMap(x))),
        wpTerm: json['wp:term'] == null ? null : List<LinkContainer>.from(json['wp:term'].map((x) => LinkContainer.fromMap(x))),
        curies: json['curies'] == null ? null : List<LinkContainer>.from(json['curies'].map((x) => LinkContainer.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'self': self == null ? null : List<dynamic>.from(self.map((x) => x.toMap())),
        'collection': collection == null ? null : List<dynamic>.from(collection.map((x) => x.toMap())),
        'about': about == null ? null : List<dynamic>.from(about.map((x) => x.toMap())),
        'author': author == null ? null : List<dynamic>.from(author.map((x) => x.toMap())),
        'replies': replies == null ? null : List<dynamic>.from(replies.map((x) => x.toMap())),
        'version-history': versionHistory == null ? null : List<dynamic>.from(versionHistory.map((x) => x.toMap())),
        'predecessor-version': predecessorVersion == null ? null : List<dynamic>.from(predecessorVersion.map((x) => x.toMap())),
        'wp:featuredmedia': wpFeaturedmedia == null ? null : List<dynamic>.from(wpFeaturedmedia.map((x) => x.toMap())),
        'wp:attachment': wpAttachment == null ? null : List<dynamic>.from(wpAttachment.map((x) => x.toMap())),
        'wp:term': wpTerm == null ? null : List<dynamic>.from(wpTerm.map((x) => x.toMap())),
        'curies': curies == null ? null : List<dynamic>.from(curies.map((x) => x.toMap())),
      };
}
