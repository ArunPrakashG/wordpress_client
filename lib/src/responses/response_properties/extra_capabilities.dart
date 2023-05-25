import 'package:meta/meta.dart';

@immutable
class ExtraCapabilities {
  const ExtraCapabilities({
    this.administrator,
  });

  factory ExtraCapabilities.fromJson(dynamic json) {
    return ExtraCapabilities(
      administrator: json?['administrator'] as bool?,
    );
  }

  final bool? administrator;

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
