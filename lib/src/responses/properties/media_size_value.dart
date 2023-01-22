class SizeValue {
  SizeValue({
    this.file,
    this.width,
    this.height,
    this.mimeType,
    this.sourceUrl,
  });

  factory SizeValue.fromJson(dynamic json) {
    return SizeValue(
      file: json['file'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      mimeType: json['mime_type'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  final String? file;
  final int? width;
  final int? height;
  final String? mimeType;
  final String? sourceUrl;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'file': file,
      'width': width,
      'height': height,
      'mime_type': mimeType,
      'source_url': sourceUrl,
    };
  }
}
