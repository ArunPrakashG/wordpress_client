import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
class Content {
  const Content({
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
