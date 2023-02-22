import 'response_properties/links.dart';

class Search {
  Search({
    this.id,
    this.title,
    this.type,
    this.subType,
    this.links,
    this.url,
  });

  Search.fromJson(dynamic json) {
    id = json?['id'] as int?;
    title = json?['title'] as String?;
    type = json?['type'] as String?;
    subType = json?['subtype'] as String?;
    url = json?['url'] as String?;
    links = json?['_links'] != null ? Links.fromJson(json['_links']) : null;
    json = json as Map<String, dynamic>?;
  }

  int? id;
  String? title;
  String? type;
  String? subType;
  Links? links;
  String? url;
  Map<String, dynamic>? json;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'title': title, 'type': type, 'subtype': subType, 'url': url, '_links': links?.toJson()};
  }
}
