import 'dart:convert';

class Guid {
  Guid({
    this.rendered,
  });

  final String rendered;

  factory Guid.fromJson(String str) => Guid.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Guid.fromMap(Map<String, dynamic> json) => Guid(
        rendered: json['rendered'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'rendered': rendered ?? '',
      };
}
