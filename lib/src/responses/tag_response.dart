import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a tag in the WordPress system.
///
/// This class encapsulates all the properties of a tag as defined in the WordPress REST API.
/// Tags are a taxonomy that can be used to classify posts (and sometimes other content types).
///
/// For more details, see: https://developer.wordpress.org/rest-api/reference/tags/
@immutable
final class Tag implements ISelfRespresentive {
  /// Creates a new [Tag] instance.
  ///
  /// All parameters correspond to the properties of a tag as defined in the WordPress REST API.
  const Tag({
    required this.id,
    required this.count,
    required this.link,
    required this.slug,
    required this.taxonomy,
    required this.self,
    this.description,
    this.name,
  });

  /// Creates a [Tag] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize tag data received from
  /// the WordPress REST API.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: castOrElse(json['id']),
      count: castOrElse(json['count']),
      description: castOrElse(json['description']),
      link: castOrElse(json['link']),
      name: castOrElse(json['name']),
      slug: castOrElse(json['slug']),
      taxonomy: castOrElse(json['taxonomy']),
      self: json,
    );
  }

  /// Unique identifier for the tag.
  final int id;

  /// Number of posts associated with the tag.
  final int count;

  /// HTML description of the tag.
  final String? description;

  /// URL of the tag.
  final String link;

  /// HTML title for the tag.
  final String? name;

  /// An alphanumeric identifier for the tag unique to its type.
  final String slug;

  /// Type of taxonomy. Always "post_tag" for tags.
  final String taxonomy;

  /// The raw JSON response from the API.
  @override
  final Map<String, dynamic> self;

  /// Converts the [Tag] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'count': count,
      'description': description,
      'link': link,
      'name': name,
      'slug': slug,
      'taxonomy': taxonomy,
    };
  }

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.count == count &&
        other.description == description &&
        other.link == link &&
        other.name == name &&
        other.slug == slug &&
        other.taxonomy == taxonomy &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        count.hashCode ^
        description.hashCode ^
        link.hashCode ^
        name.hashCode ^
        slug.hashCode ^
        taxonomy.hashCode ^
        self.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, count: $count, description: $description, link: $link, name: $name, slug: $slug, taxonomy: $taxonomy, self: $self)';
  }
}
