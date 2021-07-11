import 'dart:convert';

class Content {
  Content({
    this.rendered,
    this.protected,
  });

  final String rendered;
  final bool protected;

  factory Content.fromJson(String str) => Content.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Content.fromMap(Map<String, dynamic> json) => Content(
        rendered: json['rendered'] ?? '',
        protected: json['protected'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'rendered': rendered ?? '',
        'protected': protected ?? '',
      };
}
