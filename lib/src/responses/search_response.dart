import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

@immutable
final class Search implements ISelfRespresentive {
  const Search({
    required this.id,
    required this.type,
    required this.subType,
    required this.url,
    required this.self,
    this.title,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      id: castOrElse(json['id'])!,
      title: castOrElse(json['title']),
      type: castOrElse(json['type']),
      subType: castOrElse(json['subtype']),
      url: castOrElse(json['url']),
      self: json,
    );
  }

  final int id;
  final String? title;
  final String type;
  final String subType;
  final String url;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type,
      'subtype': subType,
      'url': url,
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
        other.url == url &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        type.hashCode ^
        subType.hashCode ^
        url.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Search(id: $id, title: $title, type: $type, subType: $subType, url: $url, self: $self)';
  }
}
