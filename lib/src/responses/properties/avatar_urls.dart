import 'package:meta/meta.dart';

import '../../library_exports.dart';

@immutable
final class AvatarUrls {
  const AvatarUrls({
    this.small24,
    this.medium48,
    this.large96,
  });

  factory AvatarUrls.fromJson(Map<String, dynamic> json) {
    return AvatarUrls(
      small24: castOrElse(json['24']),
      medium48: castOrElse(json['48']),
      large96: castOrElse(json['96']),
    );
  }

  final String? small24;
  final String? medium48;
  final String? large96;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '24': small24,
      '48': medium48,
      '96': large96,
    };
  }

  AvatarUrls copyWith({
    String? small24,
    String? medium48,
    String? large96,
  }) {
    return AvatarUrls(
      small24: small24 ?? this.small24,
      medium48: medium48 ?? this.medium48,
      large96: large96 ?? this.large96,
    );
  }

  @override
  String toString() =>
      'AvatarUrls(small24: $small24, medium48: $medium48, large96: $large96)';

  @override
  bool operator ==(covariant AvatarUrls other) {
    if (identical(this, other)) {
      return true;
    }

    return other.small24 == small24 &&
        other.medium48 == medium48 &&
        other.large96 == large96;
  }

  @override
  int get hashCode => small24.hashCode ^ medium48.hashCode ^ large96.hashCode;
}
