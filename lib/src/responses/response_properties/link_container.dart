import 'package:meta/meta.dart';

@immutable
class LinkContainer {
  const LinkContainer({
    this.id,
    this.name,
    this.taxonomy,
    this.count,
    this.embeddable,
    this.href,
  });

  factory LinkContainer.fromJson(dynamic json) {
    return LinkContainer(
      id: json['id'] as int?,
      count: json['count'] as int?,
      name: json['name'] as String?,
      taxonomy: json['taxonomy'] as String?,
      embeddable: json['embeddable'] as bool?,
      href: json['href'] as String?,
    );
  }

  final int? id;
  final String? name;
  final String? taxonomy;
  final bool? embeddable;
  final int? count;
  final String? href;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'count': count,
      'name': name,
      'taxonomy': taxonomy,
      'embeddable': embeddable,
      'href': href,
    };
  }

  @override
  String toString() {
    return 'LinkContainer(id: $id, name: $name, taxonomy: $taxonomy, embeddable: $embeddable, count: $count, href: $href)';
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
        other.href == href;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        taxonomy.hashCode ^
        embeddable.hashCode ^
        count.hashCode ^
        href.hashCode;
  }
}
