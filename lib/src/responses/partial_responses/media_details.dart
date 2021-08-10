import 'dart:convert';

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

  final int? width;
  final int? height;
  final String? file;
  final Map<String, SizeValue>? sizes;
  final ImageMeta? imageMeta;

  factory MediaDetails.fromJson(String str) => MediaDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MediaDetails.fromMap(Map<String, dynamic> json) => MediaDetails(
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
        file: json["file"] == null ? null : json["file"],
        sizes: json["sizes"] == null ? null : Map.from(json["sizes"]).map((k, v) => MapEntry<String, SizeValue>(k, SizeValue.fromMap(v))),
        imageMeta: json["image_meta"] == null ? null : ImageMeta.fromMap(json["image_meta"]),
      );

  Map<String, dynamic> toMap() => {
        "width": width == null ? null : width,
        "height": height == null ? null : height,
        "file": file == null ? null : file,
        "sizes": sizes == null ? null : Map.from(sizes!).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),
        "image_meta": imageMeta == null ? null : imageMeta!.toMap(),
      };
}
