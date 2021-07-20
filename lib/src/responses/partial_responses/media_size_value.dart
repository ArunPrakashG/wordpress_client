import 'dart:convert';

class SizeValue {
  SizeValue({
    this.file,
    this.width,
    this.height,
    this.mimeType,
    this.sourceUrl,
  });

  final String file;
  final int width;
  final int height;
  final String mimeType;
  final String sourceUrl;

  factory SizeValue.fromJson(String str) => SizeValue.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SizeValue.fromMap(Map<String, dynamic> json) => SizeValue(
        file: json["file"] == null ? null : json["file"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
        mimeType: json["mime_type"] == null ? null : json["mime_type"],
        sourceUrl: json["source_url"] == null ? null : json["source_url"],
      );

  Map<String, dynamic> toMap() => {
        "file": file == null ? null : file,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
        "mime_type": mimeType == null ? null : mimeType,
        "source_url": sourceUrl == null ? null : sourceUrl,
      };
}
