import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
class Content {
  const Content({
    required this.protected,
    this.rendered,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      rendered: castOrElse(json['rendered']),
      protected: castOrElse(json['protected'], orElse: () => false)!,
    );
  }

  final String? rendered;
  final bool protected;

  String get parsedText => parseHtmlString(rendered!);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rendered': rendered,
      'protected': protected,
    };
  }

  @override
  String toString() => 'Content(rendered: $rendered, protected: $protected)';

  @override
  bool operator ==(covariant Content other) {
    if (identical(this, other)) {
      return true;
    }

    return other.rendered == rendered && other.protected == protected;
  }

  @override
  int get hashCode => rendered.hashCode ^ protected.hashCode;
}
