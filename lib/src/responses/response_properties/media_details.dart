import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'image_meta.dart';
import 'media_size_value.dart';

@immutable
class MediaDetails {
  const MediaDetails({
    this.width,
    this.height,
    this.file,
    this.sizes,
    this.imageMeta,
  });

  factory MediaDetails.fromJson(dynamic json) {
    return MediaDetails(
      width: json?['width'] as int?,
      height: json?['height'] as int?,
      file: json?['file'] as String?,
      sizes: json?['sizes'] == null
          ? null
          : Map<String, dynamic>.from(json['sizes'] as Map<String, dynamic>)
              .map(
              (k, dynamic v) => MapEntry<String, SizeValue>(
                k,
                SizeValue.fromJson(v as Map<String, dynamic>),
              ),
            ),
      imageMeta: json?['image_meta'] == null
          ? null
          : ImageMeta.fromJson(json['image_meta'] as Map<String, dynamic>),
    );
  }

  final int? width;
  final int? height;
  final String? file;
  final Map<String, SizeValue>? sizes;
  final ImageMeta? imageMeta;

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
