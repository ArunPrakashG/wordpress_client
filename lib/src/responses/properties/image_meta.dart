import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
class ImageMeta {
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

  final String? aperture;
  final String? credit;
  final String? camera;
  final String? caption;
  final String? createdTimestamp;
  final String? copyright;
  final String? focalLength;
  final String? iso;
  final String? shutterSpeed;
  final String? title;
  final String? orientation;
  final List<dynamic> keywords;

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
