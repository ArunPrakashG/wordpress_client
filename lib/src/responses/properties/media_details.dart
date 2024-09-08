import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../library_exports.dart';
import 'image_meta.dart';
import 'media_size_value.dart';

/// Represents the details of a media item in the WordPress REST API.
///
/// This class encapsulates various properties of a media item, including its dimensions,
/// file information, different size variations, and metadata.
///
/// According to the WordPress REST API Handbook:
/// - The `width` and `height` represent the dimensions of the full-size image.
/// - The `file` property contains the relative path to the uploaded file.
/// - The `sizes` property is a map of available sizes for the image, each represented by a [SizeValue].
/// - The `image_meta` property contains additional metadata about the image.
///
/// For more information, see:
/// https://developer.wordpress.org/rest-api/reference/media/#schema-media_details
@immutable
final class MediaDetails {
  /// Creates a new [MediaDetails] instance.
  ///
  /// All parameters are optional and can be null.
  const MediaDetails({
    this.width,
    this.height,
    this.file,
    this.sizes,
    this.imageMeta,
  });

  /// Creates a [MediaDetails] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data returned by the WordPress REST API.
  factory MediaDetails.fromJson(Map<String, dynamic> json) {
    return MediaDetails(
      width: castOrElse(json['width']),
      height: castOrElse(json['height']),
      file: castOrElse(json['file']),
      sizes: castOrElse(
        json['sizes'],
        transformer: (value) {
          return Map<String, dynamic>.from(value as Map<String, dynamic>).map(
            (key, value) {
              return MapEntry(key, SizeValue.fromJson(value));
            },
          );
        },
      ),
      imageMeta: castOrElse(
        json['image_meta'],
        transformer: (value) {
          return ImageMeta.fromJson(value as Map<String, dynamic>);
        },
      ),
    );
  }

  /// The width of the full-size image, in pixels.
  final int? width;

  /// The height of the full-size image, in pixels.
  final int? height;

  /// The relative path to the uploaded file.
  final String? file;

  /// A map of available sizes for the image.
  ///
  /// Each key represents a size name (e.g., 'thumbnail', 'medium', 'large'),
  /// and the corresponding value is a [SizeValue] object containing details about that size.
  final Map<String, SizeValue>? sizes;

  /// Additional metadata about the image.
  ///
  /// This includes information such as camera settings, copyright, and other EXIF data.
  final ImageMeta? imageMeta;

  /// Converts this [MediaDetails] instance to a JSON map.
  ///
  /// This method is used for serializing the object, typically when sending data back to the WordPress REST API.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'file': file,
      'sizes': sizes == null
          ? null
          : Map<String, dynamic>.from(sizes!).map<String, dynamic>(
              (k, dynamic v) => MapEntry<String, dynamic>(
                k,
                v.toJson(),
              ),
            ),
      'image_meta': imageMeta?.toJson(),
    };
  }

  @override
  bool operator ==(covariant MediaDetails other) {
    if (identical(this, other)) {
      return true;
    }

    final mapEquals = const DeepCollectionEquality().equals;

    return other.width == width &&
        other.height == height &&
        other.file == file &&
        mapEquals(other.sizes, sizes) &&
        other.imageMeta == imageMeta;
  }

  @override
  int get hashCode {
    return width.hashCode ^
        height.hashCode ^
        file.hashCode ^
        sizes.hashCode ^
        imageMeta.hashCode;
  }

  @override
  String toString() {
    return 'MediaDetails(width: $width, height: $height, file: $file, sizes: $sizes, imageMeta: $imageMeta)';
  }
}
