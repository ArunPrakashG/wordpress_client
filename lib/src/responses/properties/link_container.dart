class LinkContainer {
  LinkContainer({
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
}
