import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

/// Represents metadata associated with an image in the WordPress REST API.
///
/// This class encapsulates various metadata properties of an image, including
/// camera settings, copyright information, and descriptive details.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/media/#schema
@immutable
final class ImageMeta {
  /// Creates an instance of [ImageMeta].
  ///
  /// All parameters are optional and can be null if not provided.
  const ImageMeta({
    this.aperture,
    this.credit,
    this.camera,
    this.caption,
    this.createdTimestamp,
    this.copyright,
    this.focalLength,
    this.iso,
    this.shutterSpeed,
    this.title,
    this.orientation,
    this.keywords = const [],
  });

  /// Creates an [ImageMeta] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize JSON data into an [ImageMeta] object.
  /// It uses the [castOrElse] utility function to safely cast values or provide defaults.
  factory ImageMeta.fromJson(Map<String, dynamic> json) {
    return ImageMeta(
      aperture: castOrElse(json['aperture']),
      credit: castOrElse(json['credit']),
      camera: castOrElse(json['camera']),
      caption: castOrElse(json['caption']),
      createdTimestamp: castOrElse(json['created_timestamp']),
      copyright: castOrElse(json['copyright']),
      focalLength: castOrElse(json['focal_length']),
      iso: castOrElse(json['iso']),
      shutterSpeed: castOrElse(json['shutter_speed']),
      title: castOrElse(json['title']),
      orientation: castOrElse(json['orientation']),
      keywords: castOrElse(
        json['keywords'],
        transformer: (value) {
          return (value as Iterable<dynamic>).toList(growable: false);
        },
        orElse: () => const <dynamic>[],
      )!,
    );
  }

  /// The aperture setting of the camera when the image was taken.
  final String? aperture;

  /// The credit or attribution for the image.
  final String? credit;

  /// The camera model used to take the image.
  final String? camera;

  /// The caption or description of the image.
  final String? caption;

  /// The timestamp when the image was created, typically in UNIX timestamp format.
  final String? createdTimestamp;

  /// The copyright information for the image.
  final String? copyright;

  /// The focal length of the camera lens when the image was taken.
  final String? focalLength;

  /// The ISO speed of the camera when the image was taken.
  final String? iso;

  /// The shutter speed of the camera when the image was taken.
  final String? shutterSpeed;

  /// The title of the image.
  final String? title;

  /// The orientation of the image (e.g., landscape, portrait).
  final String? orientation;

  /// A list of keywords or tags associated with the image.
  final List<dynamic> keywords;

  /// Converts the [ImageMeta] instance to a JSON map.
  ///
  /// This method is used for serializing the object into a format that can be
  /// easily converted to JSON for API requests or storage.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'aperture': aperture,
      'credit': credit,
      'camera': camera,
      'caption': caption,
      'created_timestamp': createdTimestamp,
      'copyright': copyright,
      'focal_length': focalLength,
      'iso': iso,
      'shutter_speed': shutterSpeed,
      'title': title,
      'orientation': orientation,
      'keywords': keywords,
    };
  }

  @override
  bool operator ==(covariant ImageMeta other) {
    if (identical(this, other)) {
      return true;
    }

    final listEquals = const DeepCollectionEquality().equals;

    return other.aperture == aperture &&
        other.credit == credit &&
        other.camera == camera &&
        other.caption == caption &&
        other.createdTimestamp == createdTimestamp &&
        other.copyright == copyright &&
        other.focalLength == focalLength &&
        other.iso == iso &&
        other.shutterSpeed == shutterSpeed &&
        other.title == title &&
        other.orientation == orientation &&
        listEquals(other.keywords, keywords);
  }

  @override
  int get hashCode {
    return aperture.hashCode ^
        credit.hashCode ^
        camera.hashCode ^
        caption.hashCode ^
        createdTimestamp.hashCode ^
        copyright.hashCode ^
        focalLength.hashCode ^
        iso.hashCode ^
        shutterSpeed.hashCode ^
        title.hashCode ^
        orientation.hashCode ^
        keywords.hashCode;
  }

  @override
  String toString() {
    return 'ImageMeta(aperture: $aperture, credit: $credit, camera: $camera, caption: $caption, createdTimestamp: $createdTimestamp, copyright: $copyright, focalLength: $focalLength, iso: $iso, shutterSpeed: $shutterSpeed, title: $title, orientation: $orientation, keywords: $keywords)';
  }
}
