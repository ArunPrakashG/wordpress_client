import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a search result from the WordPress REST API.
///
/// This class encapsulates the data returned by the WordPress REST API
/// for a search query. It includes information about the found item such as
/// its ID, title, type, and URL.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/search-results/
@immutable
final class Search implements ISelfRespresentive {
  /// Creates a new [Search] instance.
  ///
  /// [id] is the unique identifier for the search result.
  /// [type] is the object type (e.g., post, page, attachment).
  /// [subType] is the object subtype (e.g., post format or taxonomy).
  /// [url] is the full URL to view the object on the site.
  /// [self] is the raw JSON response from the API.
  /// [title] is the title of the object, if available.
  const Search({
    required this.id,
    required this.type,
    required this.subType,
    required this.url,
    required this.self,
    this.rawId,
    this.title,
  });

  /// Creates a [Search] instance from a JSON map.
  factory Search.fromJson(Map<String, dynamic> json) {
    final dynamic idJson = json['id'];
    int parsedId;
    if (idJson is int) {
      parsedId = idJson;
    } else if (idJson is String) {
      parsedId = int.tryParse(idJson) ?? 0;
    } else {
      parsedId = 0;
    }

    return Search(
      id: parsedId,
      rawId: castOrElse(json['id']),
      title: castOrElse(json['title']),
      type: castOrElse(json['type']),
      subType: castOrElse(json['subtype']),
      url: castOrElse(json['url']),
      self: json,
    );
  }

  /// The unique identifier for the object.
  final int id;

  /// The raw ID value as returned by the API (may be string or int).
  final Object? rawId;

  /// The title for the object, if available.
  final String? title;

  /// Type of object (e.g., post, page, attachment).
  final String type;

  /// Object subtype (e.g., post format or taxonomy).
  final String subType;

  /// Full URL to view the object on the site.
  final String url;

  /// The raw JSON response from the API.
  @override
  final Map<String, dynamic> self;

  /// Converts the [Search] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': rawId ?? id,
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
        other.rawId == rawId &&
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
        rawId.hashCode ^
        type.hashCode ^
        subType.hashCode ^
        url.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Search(id: $id, rawId: $rawId, title: $title, type: $type, subType: $subType, url: $url, self: $self)';
  }
}
