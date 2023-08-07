import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
class ExtraCapabilities {
  const ExtraCapabilities({
    required this.administrator,
  });

  factory ExtraCapabilities.fromJson(Map<String, dynamic> json) {
    return ExtraCapabilities(
      administrator: castOrElse(json['administrator'], orElse: () => false)!,
    );
  }

  final bool administrator;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'administrator': administrator,
    };
  }

  @override
  bool operator ==(covariant ExtraCapabilities other) {
    if (identical(this, other)) {
      return true;
    }

    return other.administrator == administrator;
  }

  @override
  int get hashCode => administrator.hashCode;

  @override
  String toString() => 'ExtraCapabilities(administrator: $administrator)';
}
