import 'package:meta/meta.dart';

import '../../library_exports.dart';

/// Represents the size details of a media item in the WordPress REST API.
///
/// This class encapsulates information about a specific size variant of a media item,
/// including its file name, dimensions, MIME type, and source URL.
///
/// For more information, see the WordPress REST API Media Endpoint documentation:
/// https://developer.wordpress.org/rest-api/reference/media/
@immutable
final class SizeValue {
  /// Creates a new [SizeValue] instance.
  ///
  /// All parameters are optional and can be null.
  const SizeValue({
    this.file,
    this.width,
    this.height,
    this.mimeType,
    this.sourceUrl,
  });

  /// Creates a [SizeValue] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data returned by the WordPress REST API.
  factory SizeValue.fromJson(Map<String, dynamic> json) {
    return SizeValue(
      file: castOrElse(json['file']),
      width: castOrElse(json['width']),
      height: castOrElse(json['height']),
      mimeType: castOrElse(json['mime_type']),
      sourceUrl: castOrElse(json['source_url']),
    );
  }

  /// The name of the file for this size variant.
  final String? file;

  /// The width of the media item in pixels.
  final int? width;

  /// The height of the media item in pixels.
  final int? height;

  /// The MIME type of the media item (e.g., 'image/jpeg', 'image/png').
  final String? mimeType;

  /// The full URL to the media item file.
  final String? sourceUrl;

  /// Converts this [SizeValue] instance to a JSON-compatible map.
  ///
  /// This method is useful for serializing the object, for example, when sending data to the API.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'file': file,
      'width': width,
      'height': height,
      'mime_type': mimeType,
      'source_url': sourceUrl,
    };
  }

  @override
  bool operator ==(covariant SizeValue other) {
    if (identical(this, other)) {
      return true;
    }

    return other.file == file &&
        other.width == width &&
        other.height == height &&
        other.mimeType == mimeType &&
        other.sourceUrl == sourceUrl;
  }

  @override
  int get hashCode {
    return file.hashCode ^
        width.hashCode ^
        height.hashCode ^
        mimeType.hashCode ^
        sourceUrl.hashCode;
  }

  @override
  String toString() {
    return 'SizeValue(file: $file, width: $width, height: $height, mimeType: $mimeType, sourceUrl: $sourceUrl)';
  }
}
