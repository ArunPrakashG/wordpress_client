import '../../utilities/helpers.dart';

class Content {
  Content({
    this.rendered,
    this.protected,
  });

  factory Content.fromJson(dynamic json) {
    return Content(
      rendered: json?['rendered'] as String?,
      protected: json?['protected'] as bool?,
    );
  }

  final String? rendered;
  final bool? protected;
  String get parsedText => parseHtmlString(rendered!);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rendered': rendered,
      'protected': protected,
    };
  }
}
