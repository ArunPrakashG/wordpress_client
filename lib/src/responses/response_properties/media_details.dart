import 'image_meta.dart';
import 'media_size_value.dart';

class MediaDetails {
  MediaDetails({
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
}
