import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

/// Represents the content of a WordPress post or page.
///
/// This class encapsulates the content data as returned by the WordPress REST API.
/// It includes both the rendered content and a flag indicating whether the content is protected.
///
/// According to the WordPress REST API Handbook:
/// - The 'rendered' field contains the HTML content of the post, transformed for display.
/// - The 'protected' field indicates whether the content is password-protected.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/posts/#schema-content
@immutable
final class Content {
  /// Creates a new [Content] instance.
  ///
  /// [protected] is required and indicates whether the content is password-protected.
  /// [rendered] is optional and contains the HTML content of the post.
  const Content({
    required this.protected,
    this.rendered,
  });

  /// Creates a [Content] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data returned by the WordPress REST API.
  /// It handles potential null values and type casting for the 'rendered' and 'protected' fields.
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      rendered: castOrElse(json['rendered']),
      protected: castOrElse(json['protected'], orElse: () => false)!,
    );
  }

  /// The HTML content of the post, transformed for display.
  ///
  /// This field may be null if the content is not available or not requested.
  final String? rendered;

  /// Indicates whether the content is password-protected.
  ///
  /// If true, the full content may not be available without authentication.
  final bool protected;

  /// Returns the parsed text content, stripped of HTML tags.
  ///
  /// This getter uses the [parseHtmlString] utility function to convert the rendered HTML
  /// to plain text. Note that this will throw an error if [rendered] is null.
  String get parsedText => parseHtmlString(rendered!);

  /// Converts the [Content] instance to a JSON map.
  ///
  /// This method is useful for serializing the content data, potentially for sending
  /// updates back to the WordPress REST API.
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
