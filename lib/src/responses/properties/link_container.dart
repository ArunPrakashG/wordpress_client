import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

/// Represents a link container in the WordPress REST API.
///
/// This class encapsulates the properties of a link, which can be used in various
/// contexts within the WordPress ecosystem, such as taxonomies, post types, or
/// other linkable entities.
///
/// For more information, see the WordPress REST API Handbook:
/// https://developer.wordpress.org/rest-api/
@immutable
final class LinkContainer {
  /// Creates a new [LinkContainer] instance.
  ///
  /// All parameters are optional and can be null.
  const LinkContainer({
    this.id,
    this.name,
    this.taxonomy,
    this.count,
    this.embeddable,
    this.href,
    this.type,
  });

  /// Creates a [LinkContainer] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data received from
  /// the WordPress REST API into a [LinkContainer] object.
  ///
  /// [json] is a map containing the JSON data.
  factory LinkContainer.fromJson(Map<String, dynamic> json) {
    return LinkContainer(
      id: castOrElse(json['id']),
      count: castOrElse(json['count']),
      name: castOrElse(json['name']),
      taxonomy: castOrElse(json['taxonomy']),
      embeddable: castOrElse(json['embeddable']),
      href: castOrElse(json['href']),
      type: castOrElse(json['type']),
    );
  }

  /// The unique identifier for the link.
  ///
  /// This is typically an integer value assigned by WordPress.
  final int? id;

  /// The human-readable name of the link.
  ///
  /// This could be the name of a taxonomy term, post type, or other entity.
  final String? name;

  /// The taxonomy to which this link belongs, if applicable.
  ///
  /// For taxonomy terms, this will be the taxonomy slug (e.g., 'category', 'tag').
  final String? taxonomy;

  /// Indicates whether the linked resource supports embedding.
  ///
  /// If true, the resource can be embedded in responses using the '_embed' parameter.
  final bool? embeddable;

  /// The count of items associated with this link, if applicable.
  ///
  /// For taxonomy terms, this might represent the number of posts in that term.
  final int? count;

  /// The URL of the linked resource.
  ///
  /// This is the full URL to the resource in the WordPress REST API.
  final String? href;

  /// The type of the linked resource.
  ///
  /// This could be 'post_type', 'taxonomy', or other resource types defined in WordPress.
  final String? type;

  /// Converts the [LinkContainer] instance to a map.
  ///
  /// This method is useful for serializing the object, for example, when sending
  /// data back to the WordPress REST API.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'count': count,
      'name': name,
      'taxonomy': taxonomy,
      'embeddable': embeddable,
      'href': href,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'LinkContainer(id: $id, name: $name, taxonomy: $taxonomy, embeddable: $embeddable, count: $count, href: $href, type: $type)';
  }

  @override
  bool operator ==(covariant LinkContainer other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id &&
        other.name == name &&
        other.taxonomy == taxonomy &&
        other.embeddable == embeddable &&
        other.count == count &&
        other.type == type &&
        other.href == href;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        taxonomy.hashCode ^
        embeddable.hashCode ^
        count.hashCode ^
        type.hashCode ^
        href.hashCode;
  }
}
