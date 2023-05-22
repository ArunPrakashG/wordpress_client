import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/self_representive_base.dart';
import 'response_properties/links.dart';

@immutable
class Search implements ISelfRespresentive {
  const Search({
    this.id,
    this.title,
    this.type,
    this.subType,
    this.links,
    this.url,
    required this.self,
  });

  factory Search.fromJson(dynamic json) {
    return Search(
      id: json?['id'] as int?,
      title: json?['title'] as String?,
      type: json?['type'] as String?,
      subType: json?['subtype'] as String?,
      url: json?['url'] as String?,
      links: json?['_links'] != null ? Links.fromJson(json['_links']) : null,
      self: json as Map<String, dynamic>,
    );
  }

  final int? id;
  final String? title;
  final String? type;
  final String? subType;
  final Links? links;
  final String? url;

  @override
  final Map<String, dynamic> self;

  @override
  Map<String, dynamic> get json => self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type,
      'subtype': subType,
      'url': url,
      '_links': links?.toJson()
    };
  }

  @override
  bool operator ==(covariant Search other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.title == title &&
        other.type == type &&
        other.subType == subType &&
        other.links == links &&
        other.url == url &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        type.hashCode ^
        subType.hashCode ^
        links.hashCode ^
        url.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Search(id: $id, title: $title, type: $type, subType: $subType, links: $links, url: $url, self: $self)';
  }
}
