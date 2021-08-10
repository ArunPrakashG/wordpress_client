import 'dart:convert';
import '../../utilities/helpers.dart';

class Content {
  Content({
    this.rendered,
    this.protected,
    this.blockVersion,
  });

  final String? rendered;
  final bool? protected;
  final int? blockVersion;
  String get parsedText => parseHtmlString(rendered!);

  factory Content.fromJson(String str) => Content.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Content.fromMap(Map<String, dynamic> json) => Content(
        rendered: json['rendered'] ?? '',
        protected: json['protected'] ?? false,
        blockVersion: json['blockVersion'] != null ? int.parse(json['blockVersion']) : 0,
      );

  Map<String, dynamic> toMap() => {
        'rendered': rendered ?? '',
        'protected': protected ?? false,
        'blockVersion': blockVersion,
      };
}
