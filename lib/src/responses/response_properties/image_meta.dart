class ImageMeta {
  ImageMeta({
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
    this.keywords,
  });

  factory ImageMeta.fromJson(dynamic json) {
    return ImageMeta(
      aperture: json['aperture'] as String?,
      credit: json['credit'] as String?,
      camera: json['camera'] as String?,
      caption: json['caption'] as String?,
      createdTimestamp: json['created_timestamp'] as String?,
      copyright: json['copyright'] as String?,
      focalLength: json['focal_length'] as String?,
      iso: json['iso'] as String?,
      shutterSpeed: json['shutter_speed'] as String?,
      title: json['title'] as String?,
      orientation: json['orientation'] as String?,
      keywords: (json['keywords'] as Iterable<dynamic>?)?.toList(),
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
  final List<dynamic>? keywords;

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
}
