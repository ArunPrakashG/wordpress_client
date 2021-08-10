import 'dart:convert';

class LinkContainer {
  LinkContainer({
    this.id,
    this.name,
    this.taxonomy,
    this.count,
    this.embeddable,
    this.href,
  });

  final int? id;
  final String? name;
  final String? taxonomy;
  final bool? embeddable;
  final int? count;
  final String? href;

  factory LinkContainer.fromJson(String str) => LinkContainer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LinkContainer.fromMap(Map<String, dynamic> json) => LinkContainer(
        id: json['id'] ?? -1,
        count: json['count'] ?? -1,
        name: json['name'] ?? '',
        taxonomy: json['taxonomy'] ?? '',
        embeddable: json['embeddable'] ?? false,
        href: json['href'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id ?? -1,
        'count': count ?? -1,
        'name': name ?? '',
        'taxonomy': taxonomy ?? '',
        'embeddable': embeddable ?? false,
        'href': href ?? '',
      };
}
